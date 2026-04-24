# Release process

This fork publishes macOS releases as a Homebrew formula with a fork-specific identity:

- Tap repo: `acoliver/homebrew-tap`
- Formula name: `bartranslate-aco`
- App name: `BarTranslateACO.app`
- Bundle identifier: `com.acoliver.BarTranslateACO`

Release artifacts are created by `.github/workflows/release.yml` and packaged by `scripts/release/package_macos.sh`.

## Creating a release

Create and push a semver tag with a leading `v`:

```sh
git tag vX.Y.Z
git push origin vX.Y.Z
```

The workflow can also be started manually from GitHub Actions with the `release_tag` input set to the same `vX.Y.Z` format. Non-semver tags are rejected.

The workflow will:

1. check out the requested tag,
2. build the `BarTranslate (GitHub)` Xcode scheme in the `Release (GitHub)` configuration,
3. set the app version from the tag,
4. package `BarTranslateACO.app` as `bartranslate-aco-vX.Y.Z-universal-apple-darwin.zip`,
5. verify the code signature,
6. upload the zip and `SHA256SUMS.txt` to the GitHub release, and
7. update `Formula/bartranslate-aco.rb` in `acoliver/homebrew-tap`.

## Required secret

The Homebrew tap update always requires this repository secret:

- `HOMEBREW_TAP_GITHUB_TOKEN`: a GitHub token that can clone, commit to, and push to `acoliver/homebrew-tap`.

## Signing modes

The release workflow supports two signing modes.

### Ad-hoc signing

If no Developer ID certificate secret is configured, the workflow uses ad-hoc signing. This keeps releases reproducible without Apple Developer Program credentials, but users may see Gatekeeper warnings because the app is not notarized.

### Developer ID signing and notarization

If `APPLE_CERTIFICATE_P12_BASE64` is set, the workflow switches to Developer ID signing and notarization. Configure all of these secrets together:

- `APPLE_CERTIFICATE_P12_BASE64`: base64-encoded Developer ID Application `.p12` certificate.
- `APPLE_CERTIFICATE_PASSWORD`: password for the `.p12` file.
- `APPLE_TEAM_ID`: Apple Developer Team ID.
- `APPLE_ID`: Apple ID used with notarization.
- `APPLE_APP_SPECIFIC_PASSWORD`: app-specific password for the Apple ID.
- `APPLE_KEYCHAIN_PASSWORD`: optional temporary CI keychain password. If omitted, the workflow uses the GitHub run ID.

Developer ID releases are submitted with `xcrun notarytool`, stapled with `xcrun stapler`, and checked with `spctl` before the final zip is created.

## Local package test

On macOS with Xcode installed, run:

```sh
scripts/release/package_macos.sh vX.Y.Z
```

By default this produces an ad-hoc signed artifact under `artifacts/release`. To test Developer ID signing locally, export the Apple variables used by the workflow and set:

```sh
export BARTRANSLATE_SIGNING_MODE=developer-id
```

Set `BARTRANSLATE_NOTARIZE=0` to skip notarization during a local Developer ID packaging smoke test.

## Homebrew installation

After a successful release and tap update:

```sh
brew tap acoliver/tap
brew install bartranslate-aco
```

The formula installs `BarTranslateACO.app` under Homebrew's prefix and provides a `bartranslate-aco` launcher script.
