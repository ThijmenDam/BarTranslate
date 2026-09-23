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

struct DefaultSettings {
  
  static let translationProvider = TranslationProvider.google
  static let menuBarIcon = MenuBarIcon.original
  
  struct ToggleApp {
    static let key = Key(string: ";")!
    static let modifier = Key(string: "⌥")!
  }
  
  struct QuickTranslate {
    static let key = Key(string: ";")!
    static let modifiers: [Key] = [.option, .shift]
  }
  
}
