#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: $0 vX.Y.Z ASSET_NAME SHA256" >&2
}

if [[ $# -ne 3 ]]; then
  usage
  exit 64
fi

release_tag="$1"
asset_name="$2"
asset_sha256="$3"

if [[ ! "${release_tag}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Release tag must look like vX.Y.Z (received: ${release_tag})" >&2
  exit 64
fi

if [[ ! "${asset_sha256}" =~ ^[0-9a-f]{64}$ ]]; then
  echo "SHA256 must be 64 lowercase hexadecimal characters" >&2
  exit 64
fi

if [[ -z "${GITHUB_REPOSITORY:-}" ]]; then
  echo "GITHUB_REPOSITORY is required" >&2
  exit 1
fi

if [[ -z "${HOMEBREW_TAP_GITHUB_TOKEN:-}" ]]; then
  echo "HOMEBREW_TAP_GITHUB_TOKEN is required" >&2
  exit 1
fi

version="${release_tag#v}"
homebrew_tap_repo="${HOMEBREW_TAP_REPO:-acoliver/homebrew-tap}"
cask_token="${HOMEBREW_CASK_TOKEN:-bartranslate-aco}"
app_name="${BARTRANSLATE_APP_NAME:-BarTranslateACO}"
bundle_identifier="${BARTRANSLATE_BUNDLE_IDENTIFIER:-com.acoliver.BarTranslateACO}"
tap_dir="$(mktemp -d)"

cleanup() {
  rm -rf "${tap_dir}"
}
trap cleanup EXIT

git clone "https://x-access-token:${HOMEBREW_TAP_GITHUB_TOKEN}@github.com/${homebrew_tap_repo}.git" "${tap_dir}"

mkdir -p "${tap_dir}/Casks"
cask_path="${tap_dir}/Casks/${cask_token}.rb"

cat > "${cask_path}" <<RUBY
cask "${cask_token}" do
  version "${version}"
  sha256 "${asset_sha256}"

  url "https://github.com/${GITHUB_REPOSITORY}/releases/download/${release_tag}/${asset_name}"
  name "${app_name}"
  desc "macOS menu bar translation app (ACO fork)"
  homepage "https://github.com/${GITHUB_REPOSITORY}"

  app "${app_name}.app"

  zap trash: [
    "~/Library/Preferences/${bundle_identifier}.plist",
  ]
end
RUBY

cd "${tap_dir}"
git config user.name "${GIT_AUTHOR_NAME:-github-actions[bot]}"
git config user.email "${GIT_AUTHOR_EMAIL:-41898282+github-actions[bot]@users.noreply.github.com}"
git add "${cask_path}"

if git diff --cached --quiet; then
  echo "Homebrew cask ${cask_token} is already up to date"
  exit 0
fi

git commit -m "${cask_token} ${version}"
git push origin HEAD
