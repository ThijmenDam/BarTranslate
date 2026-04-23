//
//  SettingsView.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 28/05/2023.
//  Redesigned UI – refined native macOS style
//

import SwiftUI
import Foundation
import HotKey

struct SettingsView: View {

    @AppStorage("translationProvider") private var translationProvider: TranslationProvider = DefaultSettings.translationProvider
    @AppStorage("showHideKey") private var showHideKey: String = DefaultSettings.ToggleApp.key.description
    @AppStorage("showHideModifier") private var showHideModifier: String = DefaultSettings.ToggleApp.modifier.description
    @AppStorage("menuBarIcon") private var menuBarIcon: MenuBarIcon = DefaultSettings.menuBarIcon
    @AppStorage("autoClipboardPaste") private var autoClipboardPaste: Bool = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                // Translation Provider
                SettingsSection(title: "Provider") {
                    SettingsRow(label: "Translation engine") {
                        Picker("", selection: $translationProvider) {
                            Text("Google Translate").tag(TranslationProvider.google)
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(width: 140)
                    }
                }

                // Keyboard shortcut
                SettingsSection(title: "Keyboard Shortcut") {
                    SettingsRow(label: "Toggle app") {
                        HStack(spacing: 6) {
                            Picker("", selection: $showHideModifier) {
                                ForEach(modifiers, id: \.self) { modifier in
                                    Text(modifier.description).tag(modifier.description)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            .frame(width: 60)

                            Text("+")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)

                            Picker("", selection: $showHideKey) {
                                ForEach(keys, id: \.self) { key in
                                    Text(key.description).tag(key.description)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            .frame(width: 60)
                        }
                    }
                }

                // Menu bar icon
                SettingsSection(title: "Menu Bar") {
                    SettingsRow(label: "Icon style") {
                        Picker("", selection: $menuBarIcon) {
                            ForEach(MenuBarIcon.allCases) { icon in
                                Image(icon.rawValue)
                                    .resizable()
                                    .scaledToFit()
                                    .tag(icon)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 80)
                    }
                }

                // Behavior
                SettingsSection(title: "Behavior") {
                    SettingsRow(label: "Auto-paste clipboard") {
                        Toggle("", isOn: $autoClipboardPaste)
                            .labelsHidden()
                    }
                }

                // About
                SettingsSection(title: "About") {
                    SettingsRow(label: "Version") {
                        Text(Bundle.main.appVersionLong)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    #if !APPSTORE
                    SettingsRow(label: "Updates") {
                        Link("Check for updates",
                             destination: URL(string: "https://github.com/ThijmenDam/BarTranslate/releases")!)
                        .font(.system(size: 12))
                    }
                    #endif
                }

                #if !APPSTORE
                // Sponsor
                Link(destination: URL(string: "https://github.com/sponsors/ThijmenDam")!) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.pink)
                        Text("Sponsor this project")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(NSColor.controlBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(NSColor.separatorColor).opacity(0.4), lineWidth: 0.5)
                            )
                    )
                }
                #endif

                // Quit
                Button(action: { exit(0) }) {
                    HStack(spacing: 6) {
                        Image(systemName: "power")
                            .font(.system(size: 11))
                        Text("Quit BarTranslate")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(Color(NSColor.systemRed))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(NSColor.systemRed).opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(NSColor.systemRed).opacity(0.15), lineWidth: 0.5)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - Settings Components

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
                .kerning(0.6)
                .padding(.leading, 4)

            VStack(spacing: 2) {
                content
            }
        }
    }
}

struct SettingsRow<Trailing: View>: View {
    let label: String
    @ViewBuilder let trailing: Trailing

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.primary)
            Spacer()
            trailing
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(NSColor.separatorColor).opacity(0.35), lineWidth: 0.5)
                )
        )
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
