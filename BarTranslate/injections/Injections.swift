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

private func doInjection(webView: WKWebView, css: String) {
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

private func fallbackCSS(provider: TranslationProvider) -> String {
  return readFileBy(name: "./\(provider)", type: "css")
}

// Injects CSS into the translation webview, such that redundant elements are hidden.
func injectCSS(webView: WKWebView, provider: TranslationProvider) {
  let sem = DispatchSemaphore.init(value: 0)
  
  // Links to the CSS that has to be injected for the corresponding translation provider
  let gistGoogle = "https://gist.github.com/ThijmenDam/6d8727f27ff1a1c5397682d866ffae9b/raw/css-injection-google.css"
  let gistDeepL = "https://gist.github.com/ThijmenDam/6d8727f27ff1a1c5397682d866ffae9b/raw/css-injection-deepl.css"
  
  let gistForSelectedProvider = provider == .google ? gistGoogle : gistDeepL
  let gistURL = URL(string: gistForSelectedProvider)!
  
  var css: String?
  
  // This task fetches the to-be-injected CSS from a GitHub Gist
  let task = URLSession.shared.dataTask(with: gistURL) { data, response, error in defer { sem.signal() }
    if let error = error {
      print("[WARNING] Failed to retrieve GitHub Gist. Reason: \(error)")
    } else if let data = data, let response = response as? HTTPURLResponse {
      if response.statusCode == 200 {
        print("Successfully fetched GitHub Gist.")
        css = String(data: data, encoding: .utf8)!
      } else {
        print("[WARNING] Failed to retrieve GitHub Gist. Reason: HTTP \(response.statusCode)")
      }
    }
  }
  
  task.resume() // Perform async task
  sem.wait()    // Wait until the semaphore has been signaled from other thread, which will be once the async task has completed
  
  let cssToInject = css ?? fallbackCSS(provider: provider)
  
  doInjection(webView: webView, css: cssToInject)
}



