#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: $0 vX.Y.Z" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 64
fi

release_tag="$1"
if [[ ! "${release_tag}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Release tag must look like vX.Y.Z (received: ${release_tag})" >&2
  exit 64
fi

version="${release_tag#v}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
artifact_dir="${repo_root}/artifacts/release"
derived_data_path="${artifact_dir}/DerivedData"
archive_path="${artifact_dir}/BarTranslateACO.xcarchive"
export_path="${artifact_dir}/export"
unsigned_app_path="${artifact_dir}/unsigned-app/BarTranslateACO.app"
app_path="${export_path}/BarTranslateACO.app"
asset_name="bartranslate-aco-${release_tag}-universal-apple-darwin.zip"
asset_path="${artifact_dir}/${asset_name}"
signing_mode="${BARTRANSLATE_SIGNING_MODE:-ad-hoc}"
configuration="Release (GitHub)"
scheme="BarTranslate (GitHub)"
project_path="${repo_root}/BarTranslate.xcodeproj"
bundle_identifier="${BARTRANSLATE_BUNDLE_IDENTIFIER:-com.acoliver.BarTranslateACO}"
app_display_name="${BARTRANSLATE_APP_NAME:-BarTranslateACO}"
team_id="${APPLE_TEAM_ID:-}"
signing_identity="${APPLE_SIGNING_IDENTITY:-}"
notary_zip_path="${artifact_dir}/notarization-${asset_name}"

rm -rf "${artifact_dir}"
mkdir -p "${artifact_dir}" "$(dirname "${unsigned_app_path}")"

common_build_settings=(
  MARKETING_VERSION="${version}"
  CURRENT_PROJECT_VERSION="${GITHUB_RUN_NUMBER:-1}"
  PRODUCT_BUNDLE_IDENTIFIER="${bundle_identifier}"
  PRODUCT_NAME="${app_display_name}"
  INFOPLIST_KEY_CFBundleDisplayName="${app_display_name}"
)

if [[ "${signing_mode}" == "developer-id" ]]; then
  if [[ -z "${team_id}" ]]; then
    echo "APPLE_TEAM_ID is required when BARTRANSLATE_SIGNING_MODE=developer-id" >&2
    exit 1
  fi

  if [[ -z "${signing_identity}" ]]; then
    signing_identity="Developer ID Application"
  fi

  xcodebuild archive \
    -project "${project_path}" \
    -scheme "${scheme}" \
    -configuration "${configuration}" \
    -archivePath "${archive_path}" \
    -destination "generic/platform=macOS" \
    -derivedDataPath "${derived_data_path}" \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY="${signing_identity}" \
    DEVELOPMENT_TEAM="${team_id}" \
    "${common_build_settings[@]}"

  cat > "${artifact_dir}/ExportOptions.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>developer-id</string>
  <key>signingStyle</key>
  <string>manual</string>
  <key>teamID</key>
  <string>${team_id}</string>
  <key>stripSwiftSymbols</key>
  <true/>
</dict>
</plist>
PLIST

  xcodebuild -exportArchive \
    -archivePath "${archive_path}" \
    -exportPath "${export_path}" \
    -exportOptionsPlist "${artifact_dir}/ExportOptions.plist"
else
  xcodebuild archive \
    -project "${project_path}" \
    -scheme "${scheme}" \
    -configuration "${configuration}" \
    -archivePath "${archive_path}" \
    -destination "generic/platform=macOS" \
    -derivedDataPath "${derived_data_path}" \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY=- \
    "${common_build_settings[@]}"

  ditto "${archive_path}/Products/Applications/BarTranslateACO.app" "${unsigned_app_path}"
  codesign --force --deep --sign - "${unsigned_app_path}"
  mkdir -p "${export_path}"
  ditto "${unsigned_app_path}" "${app_path}"
fi

if [[ ! -d "${app_path}" ]]; then
  echo "Expected app bundle was not produced at ${app_path}" >&2
  exit 1
fi

codesign --verify --deep --strict --verbose=2 "${app_path}"

if [[ "${signing_mode}" == "developer-id" && "${BARTRANSLATE_NOTARIZE:-1}" != "0" ]]; then
  if [[ -z "${APPLE_ID:-}" || -z "${APPLE_APP_SPECIFIC_PASSWORD:-}" || -z "${team_id}" ]]; then
    echo "APPLE_ID, APPLE_APP_SPECIFIC_PASSWORD, and APPLE_TEAM_ID are required for notarization" >&2
    exit 1
  fi

  ditto -c -k --keepParent "${app_path}" "${notary_zip_path}"
  xcrun notarytool submit "${notary_zip_path}" \
    --apple-id "${APPLE_ID}" \
    --password "${APPLE_APP_SPECIFIC_PASSWORD}" \
    --team-id "${team_id}" \
    --wait
  xcrun stapler staple "${app_path}"
  spctl --assess --type execute --verbose "${app_path}"
fi

ditto -c -k --keepParent "${app_path}" "${asset_path}"
sha256="$(shasum -a 256 "${asset_path}" | awk '{print $1}')"

printf "%s  %s\n" "${sha256}" "${asset_name}" > "${artifact_dir}/SHA256SUMS.txt"
printf "%s" "${asset_name}" > "${artifact_dir}/asset_name.txt"
printf "%s" "${asset_path}" > "${artifact_dir}/asset_path.txt"
printf "%s" "${sha256}" > "${artifact_dir}/sha256.txt"
printf "%s" "${version}" > "${artifact_dir}/version.txt"

echo "Packaged ${asset_path}"
echo "SHA256 ${sha256}"
