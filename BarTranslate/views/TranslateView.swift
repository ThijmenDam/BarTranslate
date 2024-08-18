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

  func makeNSView(context: Context) -> NSView {
    let containerView = NSView()
    updateNSView(containerView, context: context)
    return containerView
  }
  
  func updateNSView(_ nsView: NSView, context: Context) {
    // Remove any existing subviews 
    nsView.subviews.forEach { $0.removeFromSuperview() }
    
    // Create a new WKWebView
    let prefs = WKWebpagePreferences()
    prefs.allowsContentJavaScript = true
    
    let config = WKWebViewConfiguration()
    config.defaultWebpagePreferences = prefs
    
    let webView = WKWebView(frame: .zero, configuration: config)
    webView.isHidden = true   // Initially hides the WebView until content is fully loaded.
    
    // Set up the navigation delegate
    webView.navigationDelegate = context.coordinator
    
    // Add the WebView as a subview of the container NSView
    webView.translatesAutoresizingMaskIntoConstraints = false
    nsView.addSubview(webView)
    
    // Set constraints to fill the container view
    NSLayoutConstraint.activate([
      webView.leadingAnchor.constraint(equalTo: nsView.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: nsView.trailingAnchor),
      webView.topAnchor.constraint(equalTo: nsView.topAnchor),
      webView.bottomAnchor.constraint(equalTo: nsView.bottomAnchor)
    ])
    
    // Load the correct URL based on the translation provider
    let link = translationProvider == .google ? "https://translate.google.com" : "https://www.deepl.com/translator"
    
    guard let myURL = URL(string: link) else {
      return
    }
    
    let request = URLRequest(url: myURL)
    webView.load(request)
    
    injectCSS(webView: webView, provider: self.translationProvider)
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
