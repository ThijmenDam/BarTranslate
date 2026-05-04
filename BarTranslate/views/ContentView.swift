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

struct PopoverShape: Shape {
  let arrowWidth: CGFloat
  let arrowHeight: CGFloat
  let cornerRadius: CGFloat

  func path(in rect: CGRect) -> Path {
    let midX = rect.midX
    let arrowHalfWidth = arrowWidth / 2
    let bodyTop = rect.minY + arrowHeight
    let tipRadius: CGFloat = 3
    let baseRadius: CGFloat = 4

    var path = Path()

    path.move(to: CGPoint(x: rect.minX + cornerRadius, y: bodyTop))

    path.addArc(
      tangent1End: CGPoint(x: midX - arrowHalfWidth, y: bodyTop),
      tangent2End: CGPoint(x: midX, y: rect.minY),
      radius: baseRadius
    )

    path.addArc(
      tangent1End: CGPoint(x: midX, y: rect.minY),
      tangent2End: CGPoint(x: midX + arrowHalfWidth, y: bodyTop),
      radius: tipRadius
    )

    path.addArc(
      tangent1End: CGPoint(x: midX + arrowHalfWidth, y: bodyTop),
      tangent2End: CGPoint(x: rect.maxX, y: bodyTop),
      radius: baseRadius
    )

    path.addArc(
      tangent1End: CGPoint(x: rect.maxX, y: bodyTop),
      tangent2End: CGPoint(x: rect.maxX, y: rect.maxY),
      radius: cornerRadius
    )

    path.addArc(
      tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
      tangent2End: CGPoint(x: rect.minX, y: rect.maxY),
      radius: cornerRadius
    )

    path.addArc(
      tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
      tangent2End: CGPoint(x: rect.minX, y: bodyTop),
      radius: cornerRadius
    )

    path.addArc(
      tangent1End: CGPoint(x: rect.minX, y: bodyTop),
      tangent2End: CGPoint(x: midX - arrowHalfWidth, y: bodyTop),
      radius: cornerRadius
    )

    path.closeSubpath()
    return path
  }
}

struct ContentView: View {

  @ObservedObject var BT: BarTranslate
  @AppStorage("translationProvider") private var translationProvider: TranslationProvider = .google

  var body: some View {
    VStack(spacing: 0) {

      Color.blue
        .frame(height: Constants.ArrowSize.height)

      TopView(contentViewState: BT)

      ZStack {
        TranslateView(BT: BT)
          .zIndex(1)
          .allowsHitTesting(BT.currentView == .translate)
          .disabled(BT.currentView != .translate)
        SettingsView()
          .zIndex(BT.currentView == .translate ? 0 : 2)
          .allowsHitTesting(BT.currentView == .settings)
          .disabled(BT.currentView != .settings)
      }
    }
    .animation(nil, value: UUID())
    .frame(
      minWidth: Constants.AppSize.width,
      minHeight: Constants.AppSize.height + Constants.ArrowSize.height,
      alignment: .topLeading
    )
    .clipShape(PopoverShape(
      arrowWidth: Constants.ArrowSize.width,
      arrowHeight: Constants.ArrowSize.height,
      cornerRadius: 10
    ))
  }
  
  
  
  func goToSettings() {
    BT.currentView = .settings
  }
}
