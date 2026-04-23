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
formula_name="${HOMEBREW_FORMULA_NAME:-bartranslate-aco}"
formula_class_name="$(echo "${formula_name}" | sed -E 's/[^a-zA-Z0-9]+/ /g' | awk '{for(i=1;i<=NF;i++){printf toupper(substr($i,1,1)) tolower(substr($i,2))}}')"
release_url="https://github.com/${GITHUB_REPOSITORY}/releases/download/${release_tag}/${asset_name}"
app_name="${BARTRANSLATE_APP_NAME:-BarTranslateACO}"
bundle_identifier="${BARTRANSLATE_BUNDLE_IDENTIFIER:-com.acoliver.BarTranslateACO}"
tap_dir="$(mktemp -d)"

cleanup() {
  rm -rf "${tap_dir}"
}
trap cleanup EXIT

git clone "https://x-access-token:${HOMEBREW_TAP_GITHUB_TOKEN}@github.com/${homebrew_tap_repo}.git" "${tap_dir}"

mkdir -p "${tap_dir}/Formula"
formula_path="${tap_dir}/Formula/${formula_name}.rb"

cat > "${formula_path}" <<RUBY
class ${formula_class_name} < Formula
  desc "macOS menu bar translation app (ACO fork)"
  homepage "https://github.com/${GITHUB_REPOSITORY}"
  url "${release_url}", using: :nounzip
  version "${version}"
  sha256 "${asset_sha256}"
  license "GPL-3.0-only"

  def install
    system "ditto", "-x", "-k", cached_download, buildpath
    prefix.install "${app_name}.app"
    bin.install_symlink prefix/"${app_name}.app/Contents/MacOS/${app_name}" => "${formula_name}"
  end

  def caveats
    <<~EOS
      ${app_name}.app was installed to:
        #{prefix}/#{"${app_name}.app"}

      To launch it from Finder, open that app bundle directly. To launch it from
      a shell, run:
        ${formula_name}
    EOS
  end

  def uninstall
    system "defaults", "delete", "${bundle_identifier}" rescue nil
  end

  test do
    assert_predicate prefix/"${app_name}.app", :exist?
    assert_predicate prefix/"${app_name}.app/Contents/Info.plist", :exist?
    assert_predicate prefix/"${app_name}.app/Contents/MacOS/${app_name}", :exist?
    assert_predicate bin/"${formula_name}", :exist?
  end
end
RUBY

cd "${tap_dir}"
if [[ -f "Casks/${formula_name}.rb" ]]; then
  git rm "Casks/${formula_name}.rb"
fi

git config user.name "${GIT_AUTHOR_NAME:-github-actions[bot]}"
git config user.email "${GIT_AUTHOR_EMAIL:-41898282+github-actions[bot]@users.noreply.github.com}"
git add "${formula_path}"

if git diff --cached --quiet; then
  echo "Homebrew formula ${formula_name} is already up to date"
  exit 0
fi

git commit -m "${formula_name} ${version}"
git push origin HEAD
