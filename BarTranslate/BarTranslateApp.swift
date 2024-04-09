//
//  BarTranslateApp.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 26/05/2023.
//

import Cocoa
import SwiftUI
import HotKey

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

class AppDelegate: NSObject, NSApplicationDelegate {
  static private(set) var instance: AppDelegate!
  
  var popover: NSPopover!
  var statusBarItem: NSStatusItem!
  var hotkeyToggleApp: HotKey!
  var hotkeyToggleSettings: HotKey!
  
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
        self.togglePopover(nil)
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
    
    let contentView = ContentView()
    
    // Application Bubble
    let popover = NSPopover()
    popover.contentSize = NSSize(width: Constants.AppSize.width, height: Constants.AppSize.height)
    popover.behavior = .transient
    popover.contentViewController = NSHostingController(rootView: contentView)
    self.popover = popover
    
    // Setup status bar item
    self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
    if let button = self.statusBarItem.button {
      button.image = NSImage(named: menuBarIcon.id)
      button.action = #selector(togglePopover(_:))
    }
    
    setupToggleAppHotkeys()
  }
  
  // Show or hide BarTranslate
  @objc func togglePopover(_ sender: AnyObject?) {
    if let button = self.statusBarItem.button {
      if self.popover.isShown {
        self.popover.performClose(sender)
      } else {
        self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
      }
    }
  }
  
}

