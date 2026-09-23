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
  
  private static let labelWidth: CGFloat = 130
  
  @AppStorage("translationProvider") private var translationProvider: TranslationProvider = DefaultSettings.translationProvider
  @AppStorage("showHideKey") private var showHideKey: String = DefaultSettings.ToggleApp.key.description
  @AppStorage("showHideModifier") private var showHideModifiersRaw: String = DefaultSettings.ToggleApp.modifier.description
  @AppStorage("quickTranslateKey") private var quickTranslateKey: String = DefaultSettings.QuickTranslate.key.description
  @AppStorage("quickTranslateModifiers") private var quickTranslateModifiersRaw: String = modifiersToString(DefaultSettings.QuickTranslate.modifiers)
  @AppStorage("menuBarIcon") private var menuBarIcon: MenuBarIcon = DefaultSettings.menuBarIcon

  private var showHideModifiers: Set<String> {
    Set(showHideModifiersRaw.split(separator: ",").map(String.init))
  }

  private var quickTranslateModifiers: Set<String> {
    Set(quickTranslateModifiersRaw.split(separator: ",").map(String.init))
  }

  // Two hotkeys with no modifiers selected can never actually collide, since neither one gets registered.
  private func isDuplicate(modifiers: Set<String>, key: String, otherModifiers: Set<String>, otherKey: String) -> Bool {
    !modifiers.isEmpty && modifiers == otherModifiers && key == otherKey
  }

  private func toggledSet(_ current: Set<String>, toggling description: String, isOn: Bool) -> Set<String> {
    var mods = current
    if isOn { mods.remove(description) } else { mods.insert(description) }
    return mods
  }

  // Toggles a modifier on/off. A hotkey may end up with zero modifiers, or even identical to the other hotkey; both cases
  // are shown and resolved elsewhere rather than being blocked here, so every control stays freely editable.
  private func toggleModifier(_ modifier: Key, current: Set<String>, apply: (String) -> Void) {
    let description = modifier.description
    let mods = toggledSet(current, toggling: description, isOn: current.contains(description))
    apply(mods.sorted().joined(separator: ","))
  }

  // Toggle App always wins when both hotkeys end up configured identically; Quick Translate is disabled until changed.
  private var quickTranslateConflicts: Bool {
    isDuplicate(modifiers: quickTranslateModifiers, key: quickTranslateKey, otherModifiers: showHideModifiers, otherKey: showHideKey)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      #if !APPSTORE
      SponsorButton()
      #endif
      
      // Menu Bar Icon Toggle
      HStack {
        Text("Menu Bar Icon").frame(width: Self.labelWidth, alignment: .leading)
        Picker("", selection: $menuBarIcon) {
            ForEach(MenuBarIcon.allCases) { icon in
                Image(icon.rawValue)
                    .resizable()
                    .scaledToFit()
                    .tag(icon)
          }
        }
        .labelsHidden()
        .pickerStyle(.segmented)
        .frame(width: 100)
        Spacer()
      }
      
      Divider()
      
      HStack {
        Text("Translation Provider").frame(width: Self.labelWidth, alignment: .leading)
        Picker("", selection: $translationProvider) {
          Text("Google").tag(TranslationProvider.google)
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .frame(width: 120)
        Spacer()
      }
      
      Divider()
      
      // Toggle App and Quick Translate hotkeys, grouped into one child view so the outer VStack doesn't exceed the ViewBuilder's argument limit.
      VStack(alignment: .leading, spacing: 12) {
        hotkeyRow(
          label: "Toggle App",
          modifiers: showHideModifiers,
          keySelection: $showHideKey,
          onToggleModifier: { modifier in
            toggleModifier(modifier, current: showHideModifiers) { showHideModifiersRaw = $0 }
          }
        )
        
        hotkeyRow(
          label: "Quick Translate",
          modifiers: quickTranslateModifiers,
          keySelection: $quickTranslateKey,
          onToggleModifier: { modifier in
            toggleModifier(modifier, current: quickTranslateModifiers) { quickTranslateModifiersRaw = $0 }
          }
        )
        
        if quickTranslateConflicts {
          Text("Quick Translate is identical to Toggle App, so it's currently disabled. Change one of them to use both.")
            .font(.caption)
            .foregroundColor(.orange)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.leading, Self.labelWidth + 8)
        } else {
          Text("Translates whatever's on your clipboard.")
            .font(.caption)
            .foregroundColor(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.leading, Self.labelWidth + 8)
        }
      }
      
      Divider()
      
      // Version & Updates
      VStack(spacing: 2) {
        Spacer().frame(maxHeight: .infinity)
        Text("Version: \(Bundle.main.appVersionLong)")
        #if !APPSTORE
        Link("Check for updates", destination: URL(string: "https://github.com/ThijmenDam/BarTranslate/releases")!)
        #endif
      }
      .frame(maxWidth: .infinity)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(Color(NSColor.windowBackgroundColor))
  }
  
  @ViewBuilder
  private func hotkeyRow(
    label: String,
    modifiers activeModifiers: Set<String>,
    keySelection: Binding<String>,
    onToggleModifier: @escaping (Key) -> Void
  ) -> some View {
    HStack {
      Text(label).frame(width: Self.labelWidth, alignment: .leading)
      HStack(spacing: 4) {
        ForEach(modifiers, id: \.self) { modifier in
          let isOn = activeModifiers.contains(modifier.description)
          
          Button(modifier.description) {
            onToggleModifier(modifier)
          }
          .buttonStyle(.plain)
          .frame(minWidth: 24)
          .padding(.vertical, 4)
          .background(isOn ? Color.accentColor : Color.gray.opacity(0.25))
          .foregroundColor(isOn ? .white : .primary)
          .cornerRadius(5)
        }
      }
      Picker("", selection: keySelection) {
        ForEach(keys, id: \.self) { keyOption in
          Text(keyOption.description).tag(keyOption.description)
        }
      }
      .labelsHidden()
      .frame(width: 70)
      .disabled(activeModifiers.isEmpty)
      .opacity(activeModifiers.isEmpty ? 0.5 : 1)
      Spacer()
    }
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
