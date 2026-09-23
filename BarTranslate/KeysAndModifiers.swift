//
//  KeysAndModifiers.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 20/07/2023.
//

import HotKey
import Foundation
import Cocoa

let keys: [Key] = [
  .a,
  .b,
  .c,
  .d,
  .e,
  .f,
  .g,
  .h,
  .i,
  .j,
  .k,
  .l,
  .m,
  .n,
  .o,
  .p,
  .q,
  .r,
  .s,
  .t,
  .u,
  .v,
  .w,
  .x,
  .y,
  .z,
  .zero,
  .one,
  .two,
  .three,
  .four,
  .five,
  .six,
  .seven,
  .eight,
  .nine,
  .period,
  .quote,
  .leftBracket,
  .rightBracket,
  .semicolon,
  .slash,
  .backslash,
  .comma,
  .equal,
  .grave, // Backtick
  .minus,
]

let modifiers: [Key] = [
  .command,
  .option,
  .control,
  .shift,
]

func keyToNSEventModifierFlags(key: Key) -> NSEvent.ModifierFlags {
  switch key {
  case .command:
    return NSEvent.ModifierFlags.command
  case .option:
    return NSEvent.ModifierFlags.option
  case .control:
    return NSEvent.ModifierFlags.control
  case .shift:
    return NSEvent.ModifierFlags.shift
  default:
    return NSEvent.ModifierFlags.option
  }
}

// Combines multiple modifier keys (e.g. option + shift) into a single set of event flags for hotkeys that support more than one modifier.
func combinedModifierFlags(_ keys: [Key]) -> NSEvent.ModifierFlags {
  keys.reduce(into: []) { flags, key in flags.insert(keyToNSEventModifierFlags(key: key)) }
}

// Modifier combinations are persisted in UserDefaults as a comma-separated list of key descriptions (e.g. "⌥,⇧").
func modifiersToString(_ keys: [Key]) -> String {
  keys.map { $0.description }.joined(separator: ",")
}

func stringToModifiers(_ string: String) -> [Key] {
  string.split(separator: ",").compactMap { Key(string: String($0)) }
}
