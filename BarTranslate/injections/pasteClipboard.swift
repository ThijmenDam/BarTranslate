//
//  pasteClipboard.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 23/09/2026.
//

import Foundation
import WebKit

// Sets the translate textarea's value via its native setter (so React-style frameworks pick up the change)
// and dispatches an 'input' event so the page live-translates it, e.g. as Google Translate does.
func injectClipboardText(webView: WKWebView, text: String, provider: TranslationProvider) {
  // JSON-encode the clipboard text so it becomes a safely escaped JS string literal, regardless of its contents.
  guard let jsonData = try? JSONSerialization.data(withJSONObject: [text]),
        let jsonArray = String(data: jsonData, encoding: .utf8) else { return }
  let jsStringLiteral = jsonArray.dropFirst().dropLast() // strip the wrapping '[' and ']'

  let script = """
    (function() {
      var textarea = document.querySelector('textarea');
      if (!textarea) return;
      var nativeSetter = Object.getOwnPropertyDescriptor(window.HTMLTextAreaElement.prototype, 'value').set;
      nativeSetter.call(textarea, \(jsStringLiteral));
      textarea.dispatchEvent(new Event('input', { bubbles: true }));
      textarea.focus();
    })();
  """

  webView.evaluateJavaScript(script) { result, error in
    if let error = error {
      print("Clipboard JS injection failed: \(error)")
    } else {
      print("Clipboard text injected successfully.")
    }
  }
}
