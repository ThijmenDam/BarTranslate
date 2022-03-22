<link rel="stylesheet" href="assets/css/style.css">

<p align="center">
    <img src="assets/images/interface-snapshot.png" alt="BarTranslate interface snapshot" width="400" height="500"/>
</p>

Translations are done by presenting a simple (altered) webview of your preferred translation provider in a quick and
easily accessible interface. You can show/hide the app using `alt/option + k`.

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

* A quick and easily accessible interface for Google Translate.
* Available for MacOS, Windows and Linux.
* Hotkey `alt/option + k` to open the tanslate window.

### Planned

* Automatic dark mode based on system.
* Customizable hotkey.
* Support for Naver Papago.

## Notice for Developers

BarTranslate has recently been rewritten from scratch and made open source.
The initial app was programmed in Swift, but I have decided to move to Electron/TypeScript/React
for cross-platform compatibility and reducded development time.

I develop and test BarTranslate mainly on MacOS, meaning there <ins>may be bugs</ins>
when the app is built on Windows or Linux. If you notice any problems, feel free to open an issue or pull request.

If you want to help distribute the executables for Windows or Linux, please [let me
know](https://github.com/ThijmenDam/BarTranslate/discussions)!


## Support the author
Like my work? [Consider buying me a coffee!](https://www.paypal.me/thijmendam)