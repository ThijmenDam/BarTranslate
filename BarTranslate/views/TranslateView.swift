//
//  TranslateView.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 28/05/2023.
//

import Foundation
import SwiftUI
import WebKit

struct TranslateView: View {
  @ObservedObject var contentViewState: ContentViewState
  
  var body: some View {
    VStack(spacing: 0) {
      WebView(contentViewState: contentViewState).background(.white)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.white)
  }
}

struct WebView: NSViewRepresentable {
  @ObservedObject var contentViewState: ContentViewState
  @AppStorage("translationProvider") private var translationProvider = DefaultSettings.translationProvider
  
  func makeNSView(context: Context) -> WKWebView {
    let prefs = WKWebpagePreferences()
    prefs.allowsContentJavaScript = true
    
    let config = WKWebViewConfiguration()
    config.defaultWebpagePreferences = prefs
    
    let webView = WKWebView(frame: .zero, configuration: config)
    
    let providerURLString = translationProvider == .google ? "https://translate.google.com" : "https://www.deepl.com/translator"
    let providerURL = URL(string: providerURLString)!
    
    webView.load(URLRequest(url: providerURL))
    
    return webView
  }
  
  
  func updateNSView(_ nsView: WKWebView, context: Context) {
    switch contentViewState.currentView {
    case .translate:
      injectCSS(webView: nsView, provider: translationProvider)
    case .settings:
      return
    }
  }
}
