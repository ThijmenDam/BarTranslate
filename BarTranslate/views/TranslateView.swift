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
    print("MAKE")
    
    let prefs = WKWebpagePreferences()
    prefs.allowsContentJavaScript = true
    
    let config = WKWebViewConfiguration()
    config.defaultWebpagePreferences = prefs
    
    let webView = WKWebView(frame: .zero, configuration: config)
    
    injectCSS(webView: webView, provider: translationProvider)
    
    let providerURLString = translationProvider == .google ? "https://translate.google.com" : "https://www.deepl.com/translator"
    let providerURL = URL(string: providerURLString)!
    
    webView.load(URLRequest(url: providerURL))
    
    return webView
  }
  
  
  func updateNSView(_ nsView: WKWebView, context: Context) {
    // Only here for future reference
  }
  
  // Creates a coordinator. This method is automatically called by SwiftUI.
  func makeCoordinator() -> WebView.Coordinator {
    Coordinator(self)
  }
  
  // Coordinator class acting as event handler.
  class Coordinator: NSObject, WKNavigationDelegate {
    let parent: WebView
    
    init(_ parent: WebView) {
      self.parent = parent
    }
    
    // Delegate method called when the web view finishes loading.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      // Shows view when content is loaded.
      webView.isHidden = false
    }
  }
  
}
