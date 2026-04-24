//
//  LoginItemService.swift
//  BarTranslate
//

import Foundation
import ServiceManagement

struct LoginItemState: Equatable {
  let enabled: Bool
  let message: String?
}

enum LoginItemService {
  static func currentState() -> LoginItemState {
    guard #available(macOS 13.0, *) else {
      return LoginItemState(
        enabled: false,
        message: "Launch at login requires macOS 13 or later."
      )
    }

    switch SMAppService.mainApp.status {
    case .enabled:
      return LoginItemState(enabled: true, message: nil)
    case .requiresApproval:
      return LoginItemState(
        enabled: true,
        message: "Approval required: open System Settings → General → Login Items and allow BarTranslateACO."
      )
    case .notFound:
      return LoginItemState(
        enabled: false,
        message: "macOS could not find BarTranslateACO.app. Launch at login only works from the packaged app bundle."
      )
    case .notRegistered:
      return LoginItemState(enabled: false, message: nil)
    @unknown default:
      return LoginItemState(
        enabled: false,
        message: "macOS reported an unknown launch-at-login status."
      )
    }
  }

  static func setEnabled(_ enabled: Bool) -> LoginItemState {
    guard #available(macOS 13.0, *) else {
      return LoginItemState(
        enabled: false,
        message: "Launch at login requires macOS 13 or later."
      )
    }

    do {
      if enabled {
        try SMAppService.mainApp.register()
      } else {
        try SMAppService.mainApp.unregister()
      }
    } catch {
      return LoginItemState(
        enabled: currentState().enabled,
        message: errorMessage(for: enabled, error: error)
      )
    }

    return currentState()
  }

  private static func errorMessage(for enabled: Bool, error: Error) -> String {
    if enabled {
      return "Could not enable launch at login: \(error.localizedDescription)"
    }

    return "Could not disable launch at login: \(error.localizedDescription)"
  }
}
