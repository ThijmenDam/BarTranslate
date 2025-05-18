//
//  ContentView.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 26/05/2023.
//

import SwiftUI

enum CurrentContentView {
  case translate
  case settings
}

struct ContentView: View {
  
  @ObservedObject var popoverInfo: BarTranslate
  @AppStorage("translationProvider") private var translationProvider: TranslationProvider = .google
  
  var body: some View {
    VStack(spacing: 0) {
      
      TopView(contentViewState: popoverInfo)
      
      switch popoverInfo.currentView {
      case .translate:
        TranslateView(popoverInfo: popoverInfo)
      case .settings:
        SettingsView()
      }
    }
    .animation(nil, value: UUID())
    .frame(
      minWidth: Constants.AppSize.width,
      minHeight: Constants.AppSize.height,
      alignment: .topLeading
    )
    // Color the popover arrow
    .background(
      Color.blue
        .position(x: Constants.AppSize.width / 2, y: -Constants.AppSize.height / 2 + 10)
    )
  }
  
  func goToSettings() {
    popoverInfo.currentView = .settings
  }
}
