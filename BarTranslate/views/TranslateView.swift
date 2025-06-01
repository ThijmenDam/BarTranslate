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
  @ObservedObject var BT: BarTranslate
  @AppStorage("translationProvider") private var translationProvider = DefaultSettings.translationProvider
  
  var body: some View {
    VStack(spacing: 0) {
      WebView(BT: BT, translationProvider: translationProvider)
        .background(.white)
        .onChange(of: translationProvider) { newValue in
          BT.reloadWebView(for: translationProvider)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.white)
  }
}

struct WebView: NSViewRepresentable {
  @ObservedObject var BT: BarTranslate
  let translationProvider: TranslationProvider
  
  func makeNSView(context: Context) -> WKWebView {
    
    let prefs = WKWebpagePreferences()
    prefs.allowsContentJavaScript = true
    
    let config = WKWebViewConfiguration()
    config.defaultWebpagePreferences = prefs
    
#if DEBUG
    config.preferences.setValue(true, forKey: "developerExtrasEnabled")
#endif
    
    let webView = WKWebView(frame: .zero, configuration: config)
    
    webView.isHidden = true // the webview will be made visible once all CSS is injected
    
    BT.webView = webView
    
    return webView
  }
  
  func updateNSView(_ nsView: WKWebView, context: Context) {
    
    let coordinator = context.coordinator
    
    guard !coordinator.initialPageloadComplete else { return }
    BT.reloadWebView(for: translationProvider)
    
    coordinator.initialPageloadComplete = true
    
    nsView.navigationDelegate = context.coordinator
  }
  
  // Creates a coordinator. This method is automatically called by SwiftUI.
  func makeCoordinator() -> WebView.Coordinator {
    Coordinator(self)
  }
  
  // Coordinator class acting as event handler.
  class Coordinator: NSObject, WKNavigationDelegate {
    let parent: WebView
    var initialPageloadComplete = false
    
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
