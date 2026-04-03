//
//  ContentView.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 26/05/2023.
//  Redesigned UI – refined native macOS style
//

import SwiftUI

enum CurrentContentView {
    case translate
    case settings
}

struct ContentView: View {

    @ObservedObject var BT: BarTranslate
    @AppStorage("translationProvider") private var translationProvider: TranslationProvider = .google

    var body: some View {
        VStack(spacing: 0) {
            TopView(contentViewState: BT)

            ZStack {
                TranslateView(BT: BT)
                    .zIndex(1)
                    .allowsHitTesting(BT.currentView == .translate)
                    .opacity(BT.currentView == .translate ? 1 : 0)

                SettingsView()
                    .zIndex(BT.currentView == .translate ? 0 : 2)
                    .allowsHitTesting(BT.currentView == .settings)
                    .opacity(BT.currentView == .settings ? 1 : 0)
            }
            .animation(.easeInOut(duration: 0.15), value: BT.currentView)
        }
        .frame(
            minWidth: Constants.AppSize.width,
            minHeight: Constants.AppSize.height,
            alignment: .topLeading
        )
        // Popover arrow color – match window background instead of harsh blue
        .background(
            Color(NSColor.windowBackgroundColor)
                .position(x: Constants.AppSize.width / 2, y: -Constants.AppSize.height / 2 + 10)
        )
    }

    func goToSettings() {
        BT.currentView = .settings
    }
}
