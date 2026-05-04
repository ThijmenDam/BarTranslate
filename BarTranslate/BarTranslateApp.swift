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
    // Rendering a WindowGroup enables macOS default keyboard shortcuts (e.g. copy/paste) on macOS versions <= Monterey.
    // The WindowGroup serves no other purpose, and is thus automatically closed on startup (see 'applicationDidFinishLaunching').
    WindowGroup {
      EmptyView()
    }.commands {
      // Although the empty window group is closed on startup, the user could still force it to open using the shortcut '⌘ + N'.
      // This shouldn't be possible, thus that keyboard shortcut is disabled here.
      CommandGroup(replacing: CommandGroupPlacement.newItem) {}
    }
    Settings {
      SettingsView()
    }
  }
}

class BarTranslate: ObservableObject {
  @Published var currentView: CurrentContentView = .translate
  var webView: WKWebView?
  
  func reloadWebView(for provider: TranslationProvider) {
    guard let webView = webView else { return }

    let providerURL = URL(string: "https://translate.google.com")!
    let request = URLRequest(url: providerURL)
    
    webView.load(request)
    injectCSS(webView: webView, provider: provider)
  }
}

class KeyablePanel: NSPanel {
  override var canBecomeKey: Bool { true }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  static private(set) var instance: AppDelegate!
  
  var panel: NSPanel!
  var statusBarItem: NSStatusItem!
  var hotkeyToggleApp: HotKey!
  var hotkeyToggleSettings: HotKey!
  
  var BT: BarTranslate = BarTranslate()
    
  @AppStorage("translationProvider") private var translationProvider: TranslationProvider = DefaultSettings.translationProvider
  @AppStorage("showHideKey") private var showHideKey: String = DefaultSettings.ToggleApp.key.description
  @AppStorage("showHideModifier") private var showHideModifier: String = DefaultSettings.ToggleApp.modifier.description
  @AppStorage("menuBarIcon") private var menuBarIcon: MenuBarIcon = DefaultSettings.menuBarIcon
  
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
      contentRect: NSRect(x: 0, y: 0, width: Constants.AppSize.width, height: Constants.AppSize.height + Constants.ArrowSize.height),
      styleMask: [.borderless],
      backing: .buffered,
      defer: false)
    panel.isFloatingPanel = true
    panel.level = .floating
    panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    panel.contentViewController = NSHostingController(rootView: contentView)
    panel.isMovableByWindowBackground = false
    panel.isOpaque = false
    panel.backgroundColor = .clear
    panel.hasShadow = true
    panel.delegate = self
    self.panel = panel
    
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
      NSAnimationContext.runAnimationGroup({ context in
        context.duration = 0.15
        self.panel.animator().alphaValue = 0.0
      }) {
        self.panel.orderOut(sender)
        self.panel.alphaValue = 1.0
      }
    } else {
      positionPanel()
      panel.alphaValue = 0.0
      panel.makeKeyAndOrderFront(sender)
      NSApp.activate(ignoringOtherApps: true)

      NSAnimationContext.runAnimationGroup { context in
        context.duration = 0.15
        self.panel.animator().alphaValue = 1.0
      }

      // Autofocus HTML input
      if let webView = BT.webView, !webView.isHidden {
        injectFocusScript(webView: webView, provider: translationProvider)
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
    let panelX = buttonFrame.midX - (panelSize.width / 2)
    let panelY = buttonFrame.minY - panelSize.height - 5  // 5pt gap
    
    panel.setFrameOrigin(NSPoint(x: panelX, y: panelY))
  }
  
  func panelDidResignKey(_ notification: Notification) {
    NSAnimationContext.runAnimationGroup({ context in
      context.duration = 0.15
      self.panel.animator().alphaValue = 0.0
    }) {
      self.panel.orderOut(nil)
      self.panel.alphaValue = 1.0
    }
  }
}

extension AppDelegate: NSWindowDelegate {
  func windowDidResignKey(_ notification: Notification) {
    if let window = notification.object as? NSPanel, window == panel {
      panelDidResignKey(notification)
    }
  }
}
