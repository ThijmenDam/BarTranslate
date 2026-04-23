//
//  features.swift
//  BarTranslate
//
//  Feature injections: Copy Button, Character Counter, Clipboard Paste, Remember Languages
//

import Foundation
import WebKit
import AppKit

// MARK: - 1. Clipboard Auto-Paste

/// Injects clipboard text into the Google Translate source textarea
func injectClipboardText(webView: WKWebView, text: String) {
    let escaped = text
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "`", with: "\\`")
    let js = """
    (function() {
        function tryPaste() {
            var ta = document.querySelector('textarea');
            if (!ta) { setTimeout(tryPaste, 200); return; }
            var nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLTextAreaElement.prototype, 'value').set;
            nativeInputValueSetter.call(ta, `\(escaped)`);
            ta.dispatchEvent(new Event('input', { bubbles: true }));
            ta.dispatchEvent(new Event('change', { bubbles: true }));
            ta.focus();
        }
        tryPaste();
    })();
    """
    webView.evaluateJavaScript(js) { _, error in
        if let error = error { print("[ClipboardPaste] Error: \(error)") }
    }
}

// MARK: - 2. Character Counter (JS → Swift via messageHandler)

/// Injects JS that watches textarea input and sends char count to Swift
func injectCharCountScript(webView: WKWebView) {
    let js = """
    (function() {
        if (window.__btCharCountSetup) return;
        window.__btCharCountSetup = true;

        function setup() {
            var ta = document.querySelector('textarea');
            if (!ta) { setTimeout(setup, 400); return; }
            function report() {
                try { window.webkit.messageHandlers.charCount.postMessage(ta.value.length); } catch(e) {}
            }
            ta.addEventListener('input', report);
            report();
        }
        setup();
    })();
    """
    webView.evaluateJavaScript(js) { _, error in
        if let error = error { print("[CharCount] Error: \(error)") }
    }
}

// MARK: - 3. Copy Button – reads translation result via JS evaluation

/// Reads the translation result text from Google Translate's DOM
func readTranslationResult(from webView: WKWebView, completion: @escaping (String?) -> Void) {
    let js = """
    (function() {
        var selectors = [
            '[data-result-index="0"]',
            'span[jsname="W297wb"]',
            '.lRu31',
            '.ryNqvb',
            'c-wiz span[lang]:not([aria-label])'
        ];
        for (var sel of selectors) {
            var el = document.querySelector(sel);
            if (el) {
                var text = el.innerText.trim();
                if (text.length > 0) return text;
            }
        }
        // Broader fallback: find any non-trivial lang-attributed span
        var all = document.querySelectorAll('span[lang]');
        for (var s of all) {
            var t = s.innerText.trim();
            if (t.length > 2 && !s.closest('textarea') && !s.closest('[aria-label]')) return t;
        }
        return null;
    })();
    """
    webView.evaluateJavaScript(js) { result, _ in
        completion(result as? String)
    }
}

/// Injects a MutationObserver that pings Swift when a translation result appears/disappears
func injectResultObserverScript(webView: WKWebView) {
    let js = """
    (function() {
        if (window.__btResultObserver) return;
        window.__btResultObserver = true;

        function check() {
            var selectors = [
                '[data-result-index="0"]',
                'span[jsname="W297wb"]',
                '.lRu31', '.ryNqvb'
            ];
            for (var sel of selectors) {
                var el = document.querySelector(sel);
                if (el && el.innerText.trim().length > 0) {
                    try { window.webkit.messageHandlers.resultAvailable.postMessage(true); } catch(e) {}
                    return;
                }
            }
            try { window.webkit.messageHandlers.resultAvailable.postMessage(false); } catch(e) {}
        }

        var observer = new MutationObserver(check);
        observer.observe(document.body, { childList: true, subtree: true, characterData: true });
        check();
    })();
    """
    webView.evaluateJavaScript(js) { _, error in
        if let error = error { print("[ResultObserver] Error: \(error)") }
    }
}

// MARK: - 4. Remember Last Languages

/// Injects JS that watches URL changes and reports sl/tl params back to Swift
func injectLanguageTrackerScript(webView: WKWebView) {
    let js = """
    (function() {
        if (window.__btLangTracker) return;
        window.__btLangTracker = true;

        var lastHref = location.href;
        setInterval(function() {
            if (location.href !== lastHref) {
                lastHref = location.href;
                try { window.webkit.messageHandlers.urlChanged.postMessage(location.href); } catch(e) {}
            }
        }, 800);
        // Report initial URL
        try { window.webkit.messageHandlers.urlChanged.postMessage(location.href); } catch(e) {}
    })();
    """
    webView.evaluateJavaScript(js) { _, error in
        if let error = error { print("[LangTracker] Error: \(error)") }
    }
}

/// Parses sl/tl from a Google Translate URL string
func parseLanguageParams(from urlString: String) -> (source: String?, target: String?) {
    guard let url = URL(string: urlString),
          let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
        return (nil, nil)
    }
    let sl = components.queryItems?.first(where: { $0.name == "sl" })?.value
    let tl = components.queryItems?.first(where: { $0.name == "tl" })?.value
    return (sl, tl)
}
