//
//  TopView.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 28/05/2023.
//

import Foundation
import SwiftUI


struct SettingsButton: View {
  
  @ObservedObject var contentViewState: ContentViewState
  
  func toggleSettingsView() {
    switch contentViewState.currentView {
    case .translate:
      contentViewState.currentView = .settings
    case .settings:
      contentViewState.currentView = .translate
    }
  }
  
  var body: some View {
    Button() {
      toggleSettingsView()
    } label: {
      Image(systemName: contentViewState.currentView == .translate ? "gearshape" : "arrowshape.turn.up.backward")
        .font(.system(size: 14.0))
        .padding(.trailing, 12)
        .foregroundColor(.white)
    }.buttonStyle(.plain).keyboardShortcut(",")
  }
}

struct PowerButton: View {
  var body: some View {
    Button() {
      exit(0)
    } label: {
      Image(systemName: "power")
        .font(.system(size: 14.0, weight: .bold))
        .foregroundColor(.white)
    }
    .buttonStyle(.plain)
    
  }
}

struct TopView: View {
  @ObservedObject var contentViewState: ContentViewState
  
  var body: some View {
    HStack {
      Text("BarTranslate")
        .padding()
        .foregroundColor(.white)
      Spacer()
      HStack {
        PowerButton()
        SettingsButton(contentViewState: contentViewState)
      }
    }
    .frame(minWidth: Constants.AppSize.width)
    .background(Color.blue)
  }
}
