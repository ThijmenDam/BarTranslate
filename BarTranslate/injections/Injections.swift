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

private func cssFallbackGoogle() -> String {
  return readFileBy(name: "./google", type: "css")
}

private func cssFallbackDeepL() -> String {
  return readFileBy(name: "./deepl", type: "css")
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

func injectCSS(webView: WKWebView, provider: TranslationProvider) {
  let sem = DispatchSemaphore.init(value: 0)
  
  let gistGoogle = "https://gist.githubusercontent.com/ThijmenDam/6d8727f27ff1a1c5397682d866ffae9b/raw/"
  let gistDeepL = "TODO"
  let gist = provider == .google ? gistGoogle : gistDeepL
  let gistURL = URL(string: gist)!
  let fallbackCSS = provider == .google ? cssFallbackGoogle() : cssFallbackDeepL()
  
  var css: String?
  
  let task = URLSession.shared.dataTask(with: gistURL) { data, response, error in
    defer { sem.signal() }
    
    if let error = error {
      print("FALLBACK CSS USED. Reason: \(error)")
    } else if let data = data, let response = response as? HTTPURLResponse {
      if response.statusCode == 200 {
        css = String(data: data, encoding: .utf8)!
      } else {
        print("FALLBACK CSS USED. Reason: HTTP \(response.statusCode)")
      }
    }
  }
  
  task.resume() // Perform async task
  sem.wait()    // Wait until the semaphore has been signaled from other thread, which will be once the async task has completed
  
  doInjection(webView: webView, css: css ?? fallbackCSS)
}



