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
  
  var body: some View {
    Menu {
      Button("Preferences", action: {
        contentViewState.currentView = .settings
      })
      Divider()
      Button("Quit", action: {
        exit(0)
      })
    } label: {
      Image(systemName: "gearshape")
        .font(.system(size: 14.0))
        .foregroundColor(.white)
    }.buttonStyle(.plain)
  }
}

struct BackButton: View {
  
  @ObservedObject var contentViewState: ContentViewState
  
  var body: some View {
    Button(action: {
      contentViewState.currentView = .translate
    }) {
      Image(systemName: "chevron.left")
        .font(.system(size: 14.0))
        .foregroundColor(.white)
      Text("Translate")
        .foregroundColor(.white)
    }.buttonStyle(.plain)
  }
}

struct TopView: View {
  @ObservedObject var contentViewState: ContentViewState
  
  var body: some View {
    ZStack {
      if contentViewState.currentView == .translate {
        Text("BarTranslate")
          .padding()
          .frame(maxWidth: .infinity, alignment: .center)
          .foregroundColor(.white)
        SettingsButton(contentViewState: contentViewState)
          .frame(maxWidth: .infinity, alignment: .trailing)
          .padding()
      } else {
        BackButton(contentViewState: contentViewState)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
      }
    }
    .frame(minWidth: Constants.AppSize.width)
    .background(Color.blue)
  }
}
