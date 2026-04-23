//
//  BarTranslateApp.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 26/05/2023.
//

import Cocoa
import SwiftUI
import HotKey
import WebKit

@main
struct BarTranslateApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    WindowGroup {
      EmptyView()
    }.commands {
      CommandGroup(replacing: CommandGroupPlacement.newItem) {}
    }
    Settings {
      SettingsView()
    }
  }
}

// MARK: - Panel Configuration

private struct PanelConfig {
  /// Gap between menu bar icon and panel (in points)
  static let menuBarGap: CGFloat = 5
}

// MARK: - Keyable Panel

/// Custom NSPanel that can become key window to accept keyboard input
class KeyablePanel: NSPanel {
  override var canBecomeKey: Bool {
    return true
  }
  
  override var canBecomeMain: Bool {
    return false  // Don't become main window - prevents unwanted focus behavior
  }
}

// MARK: - BarTranslate Model

class BarTranslate: ObservableObject {
  @Published var currentView: CurrentContentView = .translate
  @Published var isLoading: Bool = true
  @Published var characterCount: Int = 0
  @Published var hasResult: Bool = false
  @Published var justCopied: Bool = false

  var webView: WKWebView?

  // Remember last language pair
  var lastSourceLang: String {
    get { UserDefaults.standard.string(forKey: "lastSourceLang") ?? "auto" }
    set { UserDefaults.standard.set(newValue, forKey: "lastSourceLang") }
  }
  var lastTargetLang: String {
    get { UserDefaults.standard.string(forKey: "lastTargetLang") ?? "en" }
    set { UserDefaults.standard.set(newValue, forKey: "lastTargetLang") }
  }

  func reloadWebView(for provider: TranslationProvider) {
    guard let webView = webView else { return }

    let sl = lastSourceLang
    let tl = lastTargetLang
    let urlString = "https://translate.google.com/?sl=\(sl)&tl=\(tl)&op=translate"
    let providerURL = URL(string: urlString)!
    let request = URLRequest(url: providerURL)

    webView.load(request)
    injectCSS(webView: webView, provider: provider)
  }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, NSApplicationDelegate {
  static private(set) var instance: AppDelegate!

  var panel: NSPanel!
  var statusBarItem: NSStatusItem!
  var hotkeyToggleApp: HotKey!

  var BT: BarTranslate = BarTranslate()

  @AppStorage("translationProvider") private var translationProvider: TranslationProvider = DefaultSettings.translationProvider
  @AppStorage("showHideKey") private var showHideKey: String = DefaultSettings.ToggleApp.key.description
  @AppStorage("showHideModifier") private var showHideModifier: String = DefaultSettings.ToggleApp.modifier.description
  @AppStorage("menuBarIcon") private var menuBarIcon: MenuBarIcon = DefaultSettings.menuBarIcon
  @AppStorage("autoClipboardPaste") private var autoClipboardPaste: Bool = false

  override init() {
    super.init()
    UserDefaults.standard.addObserver(self, forKeyPath: "showHideKey", options: .new, context: nil)
    UserDefaults.standard.addObserver(self, forKeyPath: "showHideModifier", options: .new, context: nil)
    UserDefaults.standard.addObserver(self, forKeyPath: "menuBarIcon", options: .new, context: nil)
  }

  deinit {
    UserDefaults.standard.removeObserver(self, forKeyPath: "showHideKey")
    UserDefaults.standard.removeObserver(self, forKeyPath: "showHideModifier")
    UserDefaults.standard.removeObserver(self, forKeyPath: "menuBarIcon")
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "showHideKey" || keyPath == "showHideModifier" {
      setupToggleAppHotkeys()
    }
    else if keyPath == "menuBarIcon" {
      updateMenuBarIcon()
    }
  }

  func setupToggleAppHotkeys() {
    let key = Key(string: showHideKey) ?? DefaultSettings.ToggleApp.key
    let mod = Key(string: showHideModifier) ?? DefaultSettings.ToggleApp.modifier

    hotkeyToggleApp = HotKey(
      key: key,
      modifiers: keyToNSEventModifierFlags(key: mod),
      keyDownHandler: {
        self.togglePanel(nil)
      }
    )
  }

  func updateMenuBarIcon() {
    if let button = self.statusBarItem.button {
      button.image = NSImage(named: menuBarIcon.id)
    }
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    // Immediately close the main (empty) app window defined in 'BarTranslateApp'.
    if let window = NSApplication.shared.windows.first {
      window.close()
    }

    let contentView = ContentView(BT: BT)

    // Application Panel
    let panel = KeyablePanel(
      contentRect: NSRect(x: 0, y: 0, width: Constants.AppSize.width, height: Constants.AppSize.height),
      styleMask: [.borderless],
      backing: .buffered,
      defer: false)
    panel.isFloatingPanel = true
    panel.level = .floating
    panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    panel.contentViewController = NSHostingController(rootView: contentView)
    panel.isMovableByWindowBackground = false
    panel.backgroundColor = .clear
    panel.hasShadow = true
    panel.delegate = self

    // Apply rounded corners to match popover appearance
    if let contentView = panel.contentView {
      contentView.wantsLayer = true
      contentView.layer?.cornerRadius = 12
      contentView.layer?.masksToBounds = true
    }

    self.panel = panel

    // Do not auto-close panel when debugging
    #if DEBUG
    panel.hidesOnDeactivate = false
    #endif

    // Setup status bar item
    self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
    if let button = self.statusBarItem.button {
      button.image = NSImage(named: menuBarIcon.id)
      button.action = #selector(togglePanel(_:))
    }

    setupToggleAppHotkeys()
  }

  // Show or hide BarTranslate panel
  @objc func togglePanel(_ sender: AnyObject?) {
    if panel.isVisible {
      panel.orderOut(sender)
    } else {
      positionPanel()
      panel.makeKeyAndOrderFront(sender)
      NSApp.activate(ignoringOtherApps: true)

      // Autofocus HTML input
      if let webView = BT.webView, !webView.isHidden {
        injectFocusScript(webView: webView, provider: translationProvider)

        // Auto-paste clipboard if setting enabled and clipboard has text
        if autoClipboardPaste,
           let clipText = NSPasteboard.general.string(forType: .string),
           !clipText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            injectClipboardText(webView: webView, text: clipText)
          }
        }
      }
    }
  }

  func positionPanel() {
    guard let button = statusBarItem.button else { return }
    guard let window = button.window else { return }

    // Convert button frame to screen coordinates
    let buttonFrame = window.convertToScreen(button.convert(button.bounds, to: nil))
    let panelSize = panel.frame.size

    // Position panel centered below the menu bar icon
    var panelX = buttonFrame.midX - (panelSize.width / 2)
    var panelY = buttonFrame.minY - panelSize.height - PanelConfig.menuBarGap

    // Ensure panel stays within screen boundaries
    if let screen = NSScreen.main {
      let screenFrame = screen.visibleFrame

      // Clamp horizontal position to stay on screen
      if panelX < screenFrame.minX {
        panelX = screenFrame.minX
      } else if panelX + panelSize.width > screenFrame.maxX {
        panelX = screenFrame.maxX - panelSize.width
      }

      // Ensure panel doesn't go below screen bottom
      if panelY < screenFrame.minY {
        panelY = screenFrame.minY
      }
    }

    panel.setFrameOrigin(NSPoint(x: panelX, y: panelY))
  }

  func panelDidResignKey(_ notification: Notification) {
    panel.orderOut(nil)
  }
}

extension AppDelegate: NSWindowDelegate {
  func windowDidResignKey(_ notification: Notification) {
    if let window = notification.object as? NSPanel, window == panel {
      panelDidResignKey(notification)
    }
  }
}
