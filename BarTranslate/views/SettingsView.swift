//
//  SettingsView.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 28/05/2023.
//

import SwiftUI
import Foundation
import HotKey

struct SponsorButton: View {
  var body: some View {
    Link("Sponsor This Project 😃",
         destination: URL(string: "https://github.com/sponsors/ThijmenDam")!)
    .foregroundColor(.white)
    .frame(maxWidth: .infinity, minHeight: 30)
    .background(.blue)
    .cornerRadius(6)
    .padding(.top, 2)
    .padding(.bottom, 14)
    
  }
}

struct SettingsView: View {
  
  @AppStorage("translationProvider") private var translationProvider: TranslationProvider = DefaultSettings.translationProvider
  @AppStorage("showHideKey") private var showHideKey: String = DefaultSettings.ToggleApp.key.description
  @AppStorage("showHideModifier") private var showHideModifier: String = DefaultSettings.ToggleApp.modifier.description
  @AppStorage("menuBarIcon") private var menuBarIcon: MenuBarIcon = DefaultSettings.menuBarIcon

  
  var body: some View {
    VStack {
      SponsorButton()
      
      // Translation Provider
      Form {
        Picker("Translation Provider", selection: $translationProvider) {
          Text("Google").tag(TranslationProvider.google)
          Text("DeepL").tag(TranslationProvider.deepl)
          
        }
        .pickerStyle(.menu)
      }.frame(maxWidth: .infinity)
      
      Divider().padding(.bottom, 4)
      
      // Keyboard Shortcuts
      HStack {
        Text("Toggle App")
        Form {
          Picker("Toggle App", selection: $showHideModifier) {
            ForEach(modifiers, id: \.self) { modifier in
              Text(modifier.description).tag(modifier.description)
            }
          }
          .labelsHidden()
          .pickerStyle(.menu)
          
        }.frame(maxWidth: .infinity)
        Form {
          Picker("Toggle App", selection: $showHideKey) {
            ForEach(keys, id: \.self) { key in
              Text(key.description).tag(key.description)
            }
          }.labelsHidden()
            
        }
      }
        
      // Menu Bar Icon Toggle
      HStack {
        Text("Menu Bar Icon")
        Picker("", selection: $menuBarIcon) {
            ForEach(MenuBarIcon.allCases) { icon in
                Image(icon.rawValue)
                    .resizable()
                    .scaledToFit()
                    .tag(icon)
          }
        }
        .pickerStyle(.segmented)
        .frame(width: 100)
        Spacer()
      }
      
      // Version & Updates
      VStack(spacing: 2) {
        Spacer().frame(maxHeight: .infinity)
        Text("Version: \(Bundle.main.appVersionLong)")
        Link("Check for updates", destination: URL(string: "https://github.com/ThijmenDam/BarTranslate/releases")!)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
      .frame(
        minWidth: Constants.AppSize.width,
        maxWidth: Constants.AppSize.width,
        minHeight: Constants.AppSize.height,
        maxHeight: Constants.AppSize.height
      )
  }
}
