//
//  darkMode.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 23/09/2026.
//

import Foundation
import WebKit

// Google Translate has its own native theme, entirely independent from prefers-color-scheme, cookies, or URL
// params (verified none of those affect or persist it) — simulating the actual Settings toggle click is the
// only working lever. The gear button and theme radios are matched structurally (icon path / group size)
// rather than by their (locale-dependent) label text, so this keeps working regardless of the page's language,
// and regardless of our own injected CSS hiding the header, since a programmatic click() ignores display:none.
private func googleDarkModeSyncScript(wantDark: Bool) -> String {
  """
  (function() {
    var gear = Array.prototype.find.call(document.querySelectorAll('svg path'), function(p) {
      return (p.getAttribute('d') || '').indexOf('M13.85 22.25h-3.7') === 0;
    });
    gear = gear ? gear.closest('button') : null;
    if (!gear) { return; }

    var wasExpanded = gear.getAttribute('aria-expanded') === 'true';
    if (!wasExpanded) { gear.click(); }

    var groups = {};
    document.querySelectorAll('input[type="radio"]').forEach(function(radio) {
      (groups[radio.name] = groups[radio.name] || []).push(radio);
    });
    // The theme radiogroup is the only one with exactly 2 options ("Voice speed" has 3); order is Light, Dark.
    var themeGroup = Object.keys(groups).map(function(name) { return groups[name]; }).find(function(g) {
      return g.length === 2;
    });
    if (themeGroup) {
      var wantIndex = \(wantDark ? 1 : 0);
      if (!themeGroup[wantIndex].checked) { themeGroup[wantIndex].click(); }
    }

    if (!wasExpanded) { gear.click(); }
  })();
  """
}

// Not every provider has a theme control of its own; providers without one are simply no-ops.
private func darkModeSyncScript(for provider: TranslationProvider, wantDark: Bool) -> String? {
  switch provider {
  case .google:
    return googleDarkModeSyncScript(wantDark: wantDark)
  }
}

// Syncs the translation page's own native theme (if it has one) with the app's Appearance setting.
func syncTranslationPageDarkMode(webView: WKWebView, provider: TranslationProvider, wantDark: Bool, completion: (() -> Void)? = nil) {
  guard let script = darkModeSyncScript(for: provider, wantDark: wantDark) else {
    completion?()
    return
  }

  webView.evaluateJavaScript(script) { _, error in
    if let error = error {
      print("[WARNING] Failed to sync page dark mode. Reason: \(error)")
    }
    completion?()
  }
}
