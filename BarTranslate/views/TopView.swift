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
      Image(systemName: "line.3.horizontal.decrease")
        .font(.system(size: 18))
        .foregroundColor(.white)
    }.buttonStyle(HighlightButtonStyle())
  }
}

struct BackButton: View {
  
  @ObservedObject var contentViewState: ContentViewState
  
  var body: some View {
    Button(action: {
      contentViewState.currentView = .translate
    }) {
      HStack {
        Image(systemName: "chevron.left")
          .foregroundColor(.white)
        Text("Translate")
          .foregroundColor(.white)
      }
    }.buttonStyle(HighlightButtonStyle())
  }
}

struct TopView: View {
  @ObservedObject var contentViewState: ContentViewState
  
  var body: some View {
    ZStack {
      if contentViewState.currentView == .translate {
        Text("BarTranslate")
          .frame(maxWidth: .infinity, alignment: .center)
          .foregroundColor(.white)
        SettingsButton(contentViewState: contentViewState)
          .frame(maxWidth: .infinity, alignment: .trailing)
          .padding(.trailing)
      } else {
        BackButton(contentViewState: contentViewState)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.leading)
      }
    }
    .frame(minWidth: Constants.AppSize.width, minHeight: 35)
    .background(Color.blue)
    Divider()
  }
}

/* Button Style for hover and press effect */
struct HighlightButtonStyle: ButtonStyle {
  
  @State private var isHovered = false
  var color: Color = .primary

  func makeBody(configuration: Configuration) -> some View {
    let opacity = configuration.isPressed ? 0.2 : (isHovered ? 0.1 : 0.0)
    
    configuration.label
      .padding(5)
      .background(isHovered || configuration.isPressed ? color.opacity(opacity) : .clear)
      .cornerRadius(5)
      .contentShape(Rectangle())
      .onHover { hover in
          isHovered = hover
    }
  }
}
