
# BarTranslate
🚀 A handy menu  translator widget for MacOS, Windows and Linux.

<p align="center">
    <img src="docs/assets/images/interface-snapshot.png" alt="BarTranslate interface snapshot" max-height="500"/>
</p>

Translations are done by presenting a simple (altered) webview of your preferred translation provider in a quick and
easily accessible interface.

Included support for **Google Translate** and **DeepL Translate**.

##  Installation

You can either download the executable or build the app from source.

### Download

Currently only available for MacOS (see [Notice for Developers](#notice-for-developers)).

1. Refer to the [latest releases](https://github.com/ThijmenDam/BarTranslate/releases).
2. Download BarTranslate.zip.
3. Unzip the file.
4. Place BarTranslate.app in your Applications folder.
5. Run BarTranslate.app.
6. Happy translating!

### Build From Source

Available for MacOS, Windows and Linux.

1. Clone the repository.
2. Run `yarn install` in the project root.
3. Run `npm run release` in the project root.
4. Navigate to `<project root>/out` and find your executable.

## Features

Feel free to [share your ideas](https://github.com/ThijmenDam/BarTranslate/discussions)!

* A quick and easily accessible interface for your preferred translation provider:
    * Google Translate.
    * DeepL Translate.
* Available for MacOS, Windows and Linux.
* Configurable hotkeys to:
    * Toggle the app.
    * Swap languages.
    * Select 'from' language.
    * Select 'to' language.
* Smart autofocus on the source text field when opening the app.
* Available for MacOS, Windows and Linux.
* Configurable hotkeys to:
    * Toggle the app.
    * Swap languages.
    * Select source language.
    * Select target language.
* Smart autofocus on the source text field when opening the app.

### Planned

* Dark mode.

## Notice for Developers

BarTranslate has recently been rewritten from scratch and made open source.
The initial app was programmed in Swift, but I have decided to move to Electron/TypeScript/React
for cross-platform compatibility and reduced development time.

I develop and test BarTranslate mainly on MacOS, meaning there <ins>may be bugs</ins>
when the app is built on Windows or Linux. If you notice any problems, feel free to open an issue or pull request.

If you want to help distribute the executables for Windows or Linux, please [let me
know](https://github.com/ThijmenDam/BarTranslate/discussions)!


## Support the author
Like my work? [Consider buying me a coffee!](https://github.com/sponsors/ThijmenDam)
