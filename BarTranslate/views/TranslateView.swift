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
  
  var body: some View {
    VStack(spacing: 0) {
      WebView().background(.white)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.white)
  }
}

struct WebView: NSViewRepresentable {
  @AppStorage("translationProvider") private var translationProvider = DefaultSettings.translationProvider

  func makeNSView(context: Context) -> WKWebView {
    let prefs = WKWebpagePreferences()
    prefs.allowsContentJavaScript = true
    
    let config = WKWebViewConfiguration()
    config.defaultWebpagePreferences = prefs
    
    let webView = WKWebView(frame: .zero, configuration: config)
    return webView
  }
  
  func updateNSView(_ nsView: WKWebView, context: Context) {
        
    let link = translationProvider == .google ? "https://translate.google.com" : "https://www.deepl.com/translator"
    
    guard let myURL = URL(string: link) else {
      return
    }
    
    let request = URLRequest(url: myURL)
    
    nsView.load(request)
    
    injectCSS(webView: nsView, provider: translationProvider)
  }
  
}
