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

struct DefaultSettings {
  
  static let translationProvider = TranslationProvider.google
  
  struct ToggleApp {
    static let key = Key(string: ";")!
    static let modifier = Key(string: "⌥")!
  }
  
}
