# BarTranslate Changelog

## v2.2.0 | Chinese input method compatibility 

Big thanks to [@xniPh690](https://github.com/xniPh690) for the contribution!

## v2.1.0 | macOS AppStore

BarTranslate is now also available on the macOS AppStore: https://apps.apple.com/nl/app/bartranslate/id6759278154

## v2.0.0 | Autofocus; Removed DeepL

- When opening BarTranslate, the translation input is now focussed automatically (except on startup).
- Removed DeepL due to compatibility issues with WKWebView. 

## v1.2.0 | CSS Hosted Externally

This is a nice one! 🚀

1. The CSS injected into the translation pages is now hosted [externally](https://gist.github.com/ThijmenDam/6d8727f27ff1a1c5397682d866ffae9b). This allows for interface adjustments to be made on-the-fly whenever Google or DeepL updates their translation page, eliminating the need to download a new release when this happens.

2. Fixed the briefly visible change in styling when switching from application settings to the translation view (#44). Big thanks to @BepsiKohler for the contribution!

## v1.1.0 | Configurable Menu Bar Icon

Thanks to the great work of @BepsiKohler, BarTranslate now has a configurable menu bar icon.

## v1.0.0

BarTranslate switched from Electron to SwiftUI! In other words, macOS is now natively supported.

## Prior Releases

Because BarTranslate switched from Electron to SwiftUI at version 1.0.0, prior releases are not included in this file.
