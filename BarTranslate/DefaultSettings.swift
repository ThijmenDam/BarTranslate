//
//  Settings.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 19/07/2023.
//


import Foundation
import HotKey
import AppKit

enum TranslationProvider: String {
  case google
  
  var baseURL: URL {
    switch self {
    case .google: return URL(string: "https://translate.google.com")!
    }
  }
  
  // Query param names each provider uses to encode the selected languages in its URL.
  var sourceLanguageParam: String {
    switch self {
    case .google: return "sl"
    }
  }
  
  var targetLanguageParam: String {
    switch self {
    case .google: return "tl"
    }
  }
}

enum MenuBarIcon: String, CaseIterable, Identifiable {
  case original = "MenuIcon"
  case minimal = "MenuIconMinimal"
  
  var id: String { self.rawValue }
}

enum DarkModePreference: String, CaseIterable, Identifiable {
  case system
  case light
  case dark
  
  var id: String { self.rawValue }
  
  // nil lets the app inherit the system appearance instead of forcing one.
  var appearance: NSAppearance? {
    switch self {
    case .system: return nil
    case .light: return NSAppearance(named: .aqua)
    case .dark: return NSAppearance(named: .darkAqua)
    }
  }
}

struct DefaultSettings {
  
  static let translationProvider = TranslationProvider.google
  static let menuBarIcon = MenuBarIcon.original
  static let darkModePreference = DarkModePreference.system
  
  struct ToggleApp {
    static let key = Key(string: ";")!
    static let modifier = Key(string: "⌥")!
  }
  
  struct QuickTranslate {
    static let key = Key(string: ";")!
    static let modifiers: [Key] = [.option, .shift]
  }
  
}
