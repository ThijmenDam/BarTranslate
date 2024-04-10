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

class ContentViewState: ObservableObject {
  @Published var currentView: CurrentContentView = .translate
}

struct ContentView: View {
  
  @StateObject private var contentViewState = ContentViewState()
  @AppStorage("translationProvider") private var translationProvider: TranslationProvider = .google
  
  var body: some View {
    VStack(spacing: 0) {
      
      TopView(contentViewState: contentViewState)
      
      switch contentViewState.currentView {
      case .translate:
        TranslateView()
          .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
      case .settings:
        SettingsView()
          .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
      }
    }
    .animation(.easeInOut(duration: 0.3), value: contentViewState.currentView)
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
    contentViewState.currentView = .settings
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .frame(
        minWidth: Constants.AppSize.width,
        maxWidth: Constants.AppSize.width,
        minHeight: Constants.AppSize.height,
        maxHeight: Constants.AppSize.height
      )
  }
}

