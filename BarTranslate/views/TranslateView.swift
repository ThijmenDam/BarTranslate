//
//  TranslateView.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 28/05/2023.
//  Redesigned UI + Feature overlays: copy button, char counter
//

import Foundation
import SwiftUI
import WebKit

// MARK: - TranslateView

struct TranslateView: View {
    @ObservedObject var BT: BarTranslate
    @AppStorage("translationProvider") private var translationProvider = DefaultSettings.translationProvider

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // WebView
            WebView(BT: BT, translationProvider: translationProvider)
                .onChange(of: translationProvider) { newValue in
                    BT.reloadWebView(for: newValue)
                }

            // Loading overlay
            if BT.isLoading {
                VStack(spacing: 10) {
                    ProgressView()
                        .scaleEffect(0.7)
                        .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                    Text("Loading…")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.windowBackgroundColor))
                .transition(.opacity)
            }

            // Feature overlays (hidden during loading)
            if !BT.isLoading {
                VStack(spacing: 0) {
                    Spacer()
                    HStack(alignment: .bottom) {
                        // Character counter – bottom left
                        CharCounterBadge(count: BT.characterCount)
                        Spacer()
                        // Copy button – bottom right
                        CopyResultButton(BT: BT, provider: translationProvider)
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                }
                .allowsHitTesting(true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .animation(.easeInOut(duration: 0.15), value: BT.isLoading)
    }
}

// MARK: - Character Counter Badge

struct CharCounterBadge: View {
    let count: Int
    private let limit = 5000

    private var isWarning: Bool { count > 4500 }
    private var isDanger: Bool { count >= limit }

    var body: some View {
        if count > 0 {
            Text("\(count) / \(limit)")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(isDanger ? Color(NSColor.systemRed) : isWarning ? Color(NSColor.systemOrange) : .secondary)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(.ultraThinMaterial)
                .cornerRadius(5)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .animation(.easeInOut(duration: 0.2), value: count)
        }
    }
}

// MARK: - Copy Result Button

struct CopyResultButton: View {
    @ObservedObject var BT: BarTranslate
    let provider: TranslationProvider
    @State private var isHovered = false

    var body: some View {
        if BT.hasResult {
            Button(action: copyResult) {
                HStack(spacing: 5) {
                    Image(systemName: BT.justCopied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 11, weight: .medium))
                    Text(BT.justCopied ? "Copied!" : "Copy")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(BT.justCopied ? Color(NSColor.systemGreen) : (isHovered ? .primary : .secondary))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.ultraThinMaterial)
                .cornerRadius(7)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(
                            BT.justCopied
                                ? Color(NSColor.systemGreen).opacity(0.4)
                                : Color(NSColor.separatorColor).opacity(isHovered ? 0.6 : 0.3),
                            lineWidth: 0.5
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { isHovered = $0 }
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
            .animation(.easeInOut(duration: 0.18), value: BT.hasResult)
        }
    }

    private func copyResult() {
        guard let webView = BT.webView else { return }
        readTranslationResult(from: webView) { text in
            guard let text = text, !text.isEmpty else { return }
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
            withAnimation { BT.justCopied = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { BT.justCopied = false }
            }
        }
    }
}

// MARK: - WebView

struct WebView: NSViewRepresentable {
    @ObservedObject var BT: BarTranslate
    let translationProvider: TranslationProvider

    func makeNSView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        prefs.preferredContentMode = .mobile

        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs

        // Register JS → Swift message handlers
        config.userContentController.add(context.coordinator, name: "charCount")
        config.userContentController.add(context.coordinator, name: "resultAvailable")
        config.userContentController.add(context.coordinator, name: "urlChanged")

        #if DEBUG
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        #endif

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isHidden = true
        webView.setValue(false, forKey: "drawsBackground")

        BT.webView = webView
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        guard !context.coordinator.initialPageloadComplete else { return }
        BT.reloadWebView(for: translationProvider)
        context.coordinator.initialPageloadComplete = true
        nsView.navigationDelegate = context.coordinator
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: Coordinator

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let parent: WebView
        var initialPageloadComplete = false

        init(_ parent: WebView) {
            self.parent = parent
        }

        // JS → Swift message handler
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {

            case "charCount":
                if let count = message.body as? Int {
                    DispatchQueue.main.async {
                        self.parent.BT.characterCount = count
                    }
                }

            case "resultAvailable":
                if let available = message.body as? Bool {
                    DispatchQueue.main.async {
                        withAnimation { self.parent.BT.hasResult = available }
                    }
                }

            case "urlChanged":
                if let urlString = message.body as? String {
                    let langs = parseLanguageParams(from: urlString)
                    if let sl = langs.source { self.parent.BT.lastSourceLang = sl }
                    if let tl = langs.target { self.parent.BT.lastTargetLang = tl }
                }

            default:
                break
            }
        }

        // Page finished loading — inject all feature scripts
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                withAnimation(.easeIn(duration: 0.2)) {
                    webView.isHidden = false
                    self.parent.BT.isLoading = false
                }
                // Inject feature scripts after a short delay to let page settle
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    injectCharCountScript(webView: webView)
                    injectResultObserverScript(webView: webView)
                    injectLanguageTrackerScript(webView: webView)
                }
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.BT.isLoading = true
                self.parent.BT.hasResult = false
                self.parent.BT.characterCount = 0
            }
        }
    }
}
