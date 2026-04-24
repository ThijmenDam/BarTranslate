//
//  Injections.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 28/05/2023.
//
//  References:
//  https://medium.com/@mahdi.mahjoobi/injection-css-and-javascript-in-wkwebview-eabf58e5c54e
//  https://stackoverflow.com/questions/38952420/swift-wait-until-datataskwithrequest-has-finished-to-call-the-return

import Foundation
import SwiftUI
import WebKit

private func readFileBy(name: String, type: String) -> String {
  guard let path = Bundle.main.path(forResource: name, ofType: type) else {
    return "Failed to find path"
  }

  do {
    return try String(contentsOfFile: path, encoding: .utf8)
  } catch {
    return "Couldn't read file contents"
  }
}

private func encodeStringTo64(fromString: String) -> String? {
  let plainData = fromString.data(using: .utf8)
  return plainData?.base64EncodedString(options: [])
}

private func fallbackCSS(provider: TranslationProvider) -> String {
  return readFileBy(name: "\(provider)", type: "css")
}

private func darkModeCSS() -> String {
  return """

/* Dark mode: use color inversion so Google's obfuscated DOM remains functional. */
html {
  background-color: #111 !important;
  filter: invert(90%) hue-rotate(180deg) !important;
}

body {
  background-color: #fff !important;
}

img,
video,
svg,
canvas,
[role="img"] {
  filter: invert(100%) hue-rotate(180deg) !important;
}

html,
body,
* {
  scrollbar-width: none !important;
}

html::-webkit-scrollbar,
body::-webkit-scrollbar,
*::-webkit-scrollbar {
  width: 0 !important;
  height: 0 !important;
  display: none !important;
}

"""
}

private func cssForInjection(provider: TranslationProvider) -> String {
  var cssToInject = fallbackCSS(provider: provider)
  if isSystemDarkMode() {
    cssToInject += darkModeCSS()
  }
  return cssToInject
}

private func cssInjectionJavaScript(css: String) -> String? {
  guard let encodedCSS = encodeStringTo64(fromString: css) else { return nil }

  return """
(function() {
  var existing = document.getElementById('BarTranslate-css');
  if (existing) { existing.remove(); }

  var style = document.createElement('style');
  style.id = 'BarTranslate-css';
  style.type = 'text/css';
  style.textContent = window.atob('\(encodedCSS)');

  var parent = document.getElementsByTagName('head').item(0) || document.documentElement;
  parent.appendChild(style);
})();
"""
}

func isSystemDarkMode() -> Bool {
  if let match = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) {
    return match == .darkAqua
  }

  return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
}

func updateDarkMode(webView: WKWebView, provider: TranslationProvider) {
  let cssToInject = cssForInjection(provider: provider)
  guard let javascript = cssInjectionJavaScript(css: cssToInject) else { return }

  webView.evaluateJavaScript(javascript) { _, error in
    if let error = error {
      print("Dark mode CSS update failed: \(error)")
    }
  }
}

// Registers CSS before navigation starts.
func injectCSS(webView: WKWebView, provider: TranslationProvider) {
  let cssToInject = cssForInjection(provider: provider)
  guard let javascript = cssInjectionJavaScript(css: cssToInject) else { return }

  // DELETE CACHE
  WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler:{ })

  webView.configuration.userContentController.removeAllUserScripts()
  webView.configuration.userContentController.addUserScript(
    WKUserScript(source: javascript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
  )
  print("Injected CSS for \(provider)")
}

// Applies CSS after navigation completes. This is needed because registering a
// WKUserScript can miss the current page if navigation has already committed.
func applyCSS(webView: WKWebView, provider: TranslationProvider) {
  let cssToInject = cssForInjection(provider: provider)
  guard let javascript = cssInjectionJavaScript(css: cssToInject) else { return }

  webView.evaluateJavaScript(javascript) { _, error in
    if let error = error {
      print("CSS injection failed: \(error)")
    }
  }
}
