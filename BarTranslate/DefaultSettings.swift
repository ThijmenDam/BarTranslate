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
  case google, deepl
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
  
}
