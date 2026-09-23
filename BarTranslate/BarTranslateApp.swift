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

class BarTranslate: NSObject, ObservableObject {
  @Published var currentView: CurrentContentView = .translate
  // Whether the webview has finished its initial page load; unrelated to whether it's currently the visible tab.
  @Published var webViewLoaded = false
  var webView: WKWebView?
  private var currentProvider: TranslationProvider = DefaultSettings.translationProvider
  
  @AppStorage("darkModePreference") private var darkModePreference = DefaultSettings.darkModePreference
  
  static let languageChangeMessageName = "languageChanged"
  
  // Google Translate reflects the selected languages in its URL via history.pushState, which never triggers a full
  // navigation (and isn't reliably observable via WKWebView's `url` KVO), so notify Swift ourselves instead.
  static let languageChangeHookScript = WKUserScript(
    source: """
      (function() {
        function notifyLanguageChange() {
          window.webkit.messageHandlers.\(languageChangeMessageName).postMessage(location.href);
        }
        var originalPushState = history.pushState;
        history.pushState = function() {
          originalPushState.apply(history, arguments);
          notifyLanguageChange();
        };
        var originalReplaceState = history.replaceState;
        history.replaceState = function() {
          originalReplaceState.apply(history, arguments);
          notifyLanguageChange();
        };
        window.addEventListener('popstate', notifyLanguageChange);
      })();
    """,
    injectionTime: .atDocumentStart,
    forMainFrameOnly: true
  )
  
  func reloadWebView(for provider: TranslationProvider) {
    guard let webView = webView else { return }
    currentProvider = provider

    let request = URLRequest(url: providerURL(for: provider))
    
    webView.load(request)
    injectCSS(webView: webView, provider: provider)
  }
  
  // Restores the last-used source/target languages for this provider, if any were saved.
  private func providerURL(for provider: TranslationProvider) -> URL {
    var components = URLComponents(url: provider.baseURL, resolvingAgainstBaseURL: false)!
    
    if let sourceLanguage = UserDefaults.standard.string(forKey: sourceLanguageKey(for: provider)),
       let targetLanguage = UserDefaults.standard.string(forKey: targetLanguageKey(for: provider)) {
      components.queryItems = [
        URLQueryItem(name: provider.sourceLanguageParam, value: sourceLanguage),
        URLQueryItem(name: provider.targetLanguageParam, value: targetLanguage)
      ]
    }
    
    return components.url!
  }
  
  private func sourceLanguageKey(for provider: TranslationProvider) -> String {
    "preferredSourceLanguage_\(provider.rawValue)"
  }
  
  private func targetLanguageKey(for provider: TranslationProvider) -> String {
    "preferredTargetLanguage_\(provider.rawValue)"
  }
  
  // Syncs the current provider's own native theme (if it has one) with the resolved Appearance setting.
  func syncPageDarkMode(completion: (() -> Void)? = nil) {
    guard let webView = webView else {
      completion?()
      return
    }
    
    syncTranslationPageDarkMode(webView: webView, provider: currentProvider, wantDark: darkModePreference.resolvedIsDark, completion: completion)
  }
}

extension BarTranslate: WKScriptMessageHandler {
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    guard message.name == Self.languageChangeMessageName,
          let urlString = message.body as? String,
          let url = URL(string: urlString),
          let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else { return }
    
    if let sourceLanguage = queryItems.first(where: { $0.name == currentProvider.sourceLanguageParam })?.value {
      UserDefaults.standard.set(sourceLanguage, forKey: sourceLanguageKey(for: currentProvider))
    }
    if let targetLanguage = queryItems.first(where: { $0.name == currentProvider.targetLanguageParam })?.value {
      UserDefaults.standard.set(targetLanguage, forKey: targetLanguageKey(for: currentProvider))
    }
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
  var hotkeyQuickTranslate: HotKey!
  
  var BT: BarTranslate = BarTranslate()
    
  @AppStorage("translationProvider") private var translationProvider: TranslationProvider = DefaultSettings.translationProvider
  @AppStorage("showHideKey") private var showHideKey: String = DefaultSettings.ToggleApp.key.description
  @AppStorage("showHideModifier") private var showHideModifiers: String = DefaultSettings.ToggleApp.modifier.description
  @AppStorage("quickTranslateKey") private var quickTranslateKey: String = DefaultSettings.QuickTranslate.key.description
  @AppStorage("quickTranslateModifiers") private var quickTranslateModifiers: String = modifiersToString(DefaultSettings.QuickTranslate.modifiers)
  @AppStorage("menuBarIcon") private var menuBarIcon: MenuBarIcon = DefaultSettings.menuBarIcon
  @AppStorage("darkModePreference") private var darkModePreference: DarkModePreference = DefaultSettings.darkModePreference
  
  override init() {
    super.init()
    UserDefaults.standard.addObserver(self, forKeyPath: "showHideKey", options: .new, context: nil)
    UserDefaults.standard.addObserver(self, forKeyPath: "showHideModifier", options: .new, context: nil)
    UserDefaults.standard.addObserver(self, forKeyPath: "quickTranslateKey", options: .new, context: nil)
    UserDefaults.standard.addObserver(self, forKeyPath: "quickTranslateModifiers", options: .new, context: nil)
    UserDefaults.standard.addObserver(self, forKeyPath: "menuBarIcon", options: .new, context: nil)
    UserDefaults.standard.addObserver(self, forKeyPath: "darkModePreference", options: .new, context: nil)
  }
  
  deinit {
    UserDefaults.standard.removeObserver(self, forKeyPath: "showHideKey")
    UserDefaults.standard.removeObserver(self, forKeyPath: "showHideModifier")
    UserDefaults.standard.removeObserver(self, forKeyPath: "quickTranslateKey")
    UserDefaults.standard.removeObserver(self, forKeyPath: "quickTranslateModifiers")
    UserDefaults.standard.removeObserver(self, forKeyPath: "menuBarIcon")
    UserDefaults.standard.removeObserver(self, forKeyPath: "darkModePreference")
    NSApp.removeObserver(self, forKeyPath: "effectiveAppearance")
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "showHideKey" || keyPath == "showHideModifier" {
      setupToggleAppHotkeys()
      // Toggle App always wins ties, so a change to it can resolve (or create) a conflict with the Quick Translate hotkey.
      setupQuickTranslateHotkey()
    }
    else if keyPath == "quickTranslateKey" || keyPath == "quickTranslateModifiers" {
      setupQuickTranslateHotkey()
    }
    else if keyPath == "menuBarIcon" {
      updateMenuBarIcon()
    }
    else if keyPath == "darkModePreference" {
      updateDarkModeAppearance()
      BT.syncPageDarkMode()
    }
    else if keyPath == "effectiveAppearance" {
      BT.syncPageDarkMode()
    }
  }
  
  func setupToggleAppHotkeys() {
    
    let key = Key(string: showHideKey) ?? DefaultSettings.ToggleApp.key
    let mods = stringToModifiers(showHideModifiers)
    
    // No modifiers selected means this hotkey is turned off; don't register a bare-key global shortcut.
    guard !mods.isEmpty else {
      hotkeyToggleApp = nil
      return
    }
    
    hotkeyToggleApp = HotKey(
      key: key,
      modifiers: combinedModifierFlags(mods),
      keyDownHandler: {
        self.togglePanel(nil)
      }
    )
  }
  
  func setupQuickTranslateHotkey() {
    
    let key = Key(string: quickTranslateKey) ?? DefaultSettings.QuickTranslate.key
    let mods = stringToModifiers(quickTranslateModifiers)
    
    // An empty modifier set turns the hotkey off; an exact match with Toggle App also disables it, since that one always wins.
    let toggleAppKey = Key(string: showHideKey) ?? DefaultSettings.ToggleApp.key
    let toggleAppMods = Set(stringToModifiers(showHideModifiers).map { $0.description })
    let conflictsWithToggleApp = !toggleAppMods.isEmpty && toggleAppMods == Set(mods.map { $0.description }) && key == toggleAppKey
    
    guard !mods.isEmpty, !conflictsWithToggleApp else {
      hotkeyQuickTranslate = nil
      return
    }
    
    hotkeyQuickTranslate = HotKey(
      key: key,
      modifiers: combinedModifierFlags(mods),
      keyDownHandler: {
        self.quickTranslate()
      }
    )
  }
  
  func updateMenuBarIcon() {
    if let button = self.statusBarItem.button {
      button.image = NSImage(named: menuBarIcon.id)
    }
  }
  
  // Forces the app's own appearance into the chosen one, or nil to follow the system.
  func updateDarkModeAppearance() {
    NSApp.appearance = darkModePreference.appearance
  }
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    
    // Only relevant when following 'system', but cheap enough to always observe; resolvedIsDark handles the rest.
    // Registered here rather than in 'init', since NSApp isn't ready yet that early in the app lifecycle.
    NSApp.addObserver(self, forKeyPath: "effectiveAppearance", options: .new, context: nil)
    
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
    panel.animationBehavior = .utilityWindow
    panel.delegate = self
    self.panel = panel
    
    // Setup status bar item
    self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
    if let button = self.statusBarItem.button {
      button.image = NSImage(named: menuBarIcon.id)
      button.action = #selector(togglePanel(_:))
    }
    
    setupToggleAppHotkeys()
    setupQuickTranslateHotkey()
    updateDarkModeAppearance()
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
      if let webView = BT.webView, BT.webViewLoaded {
        injectFocusScript(webView: webView, provider: translationProvider)
      }
    }
  }
  
  // Shows the panel (bringing it to front if already open) and immediately translates whatever's on the clipboard.
  @objc func quickTranslate() {
    BT.currentView = .translate
    
    if !panel.isVisible {
      positionPanel()
      panel.makeKeyAndOrderFront(nil)
    }
    NSApp.activate(ignoringOtherApps: true)
    panel.makeKey()
    
    guard let webView = BT.webView, BT.webViewLoaded else { return }
    
    if let clipboardText = NSPasteboard.general.string(forType: .string), !clipboardText.isEmpty {
      injectClipboardText(webView: webView, text: clipboardText, provider: translationProvider)
    } else {
      injectFocusScript(webView: webView, provider: translationProvider)
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
