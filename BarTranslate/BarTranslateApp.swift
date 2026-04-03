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
        get { UserDefaults.standard.string(forKey: "lastTargetLang") ?? "vi" }
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

    var popover: NSPopover!
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
        } else if keyPath == "menuBarIcon" {
            updateMenuBarIcon()
        }
    }

    func setupToggleAppHotkeys() {
        let key = Key(string: showHideKey) ?? DefaultSettings.ToggleApp.key
        let mod = Key(string: showHideModifier) ?? DefaultSettings.ToggleApp.modifier

        hotkeyToggleApp = HotKey(
            key: key,
            modifiers: keyToNSEventModifierFlags(key: mod),
            keyDownHandler: { self.togglePopover(nil) }
        )
    }

    func updateMenuBarIcon() {
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: menuBarIcon.id)
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first { window.close() }

        let contentView = ContentView(BT: BT)

        let popover = NSPopover()
        popover.contentSize = NSSize(width: Constants.AppSize.width, height: Constants.AppSize.height)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover

        #if DEBUG
        popover.behavior = .applicationDefined
        #endif

        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: menuBarIcon.id)
            button.action = #selector(togglePopover(_:))
        }

        setupToggleAppHotkeys()
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        guard let button = self.statusBarItem.button else { return }

        if self.popover.isShown {
            self.popover.performClose(sender)
        } else {
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)

            guard let webView = BT.webView, !webView.isHidden else { return }

            // Autofocus textarea
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
