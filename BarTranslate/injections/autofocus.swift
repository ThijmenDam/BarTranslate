//
//  focusInjection.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 18/05/2025.
//

import Foundation
import WebKit

func injectFocusScript(webView: WKWebView, provider: TranslationProvider) {
  let script = "document.querySelector('textarea').focus();"

  webView.evaluateJavaScript(script) { result, error in
    if let error = error {
      print("Autofocus JS injection failed: \(error)")
    } else {
      print("Autofocus JS injected successfully.")
    }
  }
}
