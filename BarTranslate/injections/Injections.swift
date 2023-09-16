//
//  Injections.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 28/05/2023.
//
//  Reference: https://medium.com/@mahdi.mahjoobi/injection-css-and-javascript-in-wkwebview-eabf58e5c54e

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

private func cssGoogle() -> String {
  return readFileBy(name: "./google", type: "css")
}

private func cssDeepL() -> String {
  return readFileBy(name: "./deepl", type: "css")
}

func injectCSS(webView: WKWebView, provider: TranslationProvider) {
  let css: String = provider == .google ? cssGoogle() : cssDeepL();
  
  let javascript = """
      javascript:(function() {
      var parent = document.getElementsByTagName('head').item(0);
      var style = document.createElement('style');
      style.type = 'text/css';
      style.innerHTML = window.atob('\(encodeStringTo64(fromString: css)!)');
      parent.appendChild(style)})()
  """
  
  webView.configuration.userContentController.addUserScript(
    WKUserScript(source: javascript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
  )
}



