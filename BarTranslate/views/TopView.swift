//
//  TopView.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 28/05/2023.
//  Redesigned UI – refined native macOS style
//

import Foundation
import SwiftUI

struct TopView: View {
    @ObservedObject var contentViewState: BarTranslate

    var body: some View {
        HStack(spacing: 8) {
            // App icon / brand
            Image(systemName: "translate")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)

            Text("BarTranslate")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)

            Spacer()

            // Tab switcher
            HStack(spacing: 2) {
                NavTabButton(
                    icon: "text.bubble",
                    label: "Translate",
                    isActive: contentViewState.currentView == .translate
                ) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        contentViewState.currentView = .translate
                    }
                }
                NavTabButton(
                    icon: "gearshape",
                    label: "Settings",
                    isActive: contentViewState.currentView == .settings
                ) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        contentViewState.currentView = .settings
                    }
                }
            }
            .padding(2)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor))
            )

            // Quit button
            TopBarIconButton(icon: "power") {
                exit(0)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(NSColor.separatorColor).opacity(0.7)),
            alignment: .bottom
        )
        .frame(minWidth: Constants.AppSize.width)
    }
}

// MARK: - Nav Tab Button

struct NavTabButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                Text(label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(isActive ? .primary : .secondary)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isActive
                          ? Color(NSColor.windowBackgroundColor)
                          : (isHovered ? Color(NSColor.windowBackgroundColor).opacity(0.6) : Color.clear))
                    .shadow(color: isActive ? Color.black.opacity(0.07) : .clear, radius: 2, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { isHovered = $0 }
        .keyboardShortcut(label == "Settings" ? "," : KeyEquivalent("\0"), modifiers: [])
    }
}

// MARK: - Top Bar Icon Button

struct TopBarIconButton: View {
    let icon: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isHovered ? .primary : .secondary)
                .frame(width: 26, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isHovered ? Color(NSColor.controlBackgroundColor) : Color.clear)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { isHovered = $0 }
    }
}
