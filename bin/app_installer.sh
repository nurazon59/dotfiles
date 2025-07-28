#!/usr/bin/env bash
# Install or update GUI applications without Homebrew / npm / mas‑cli
# Strategy:
#   * .pkg   → installer
#   * .dmg   → hdiutil attach → copy .app → detach
#   * .zip   → unzip → copy .app
#   * Latest GitHub releases fetched via REST API + jq when possible

set -euo pipefail

DOWNLOAD_DIR="${HOME}/Downloads/app_installer_cache"
mkdir -p "${DOWNLOAD_DIR}"

command_exists() { command -v "$1" >/dev/null 2>&1; }

# -----------------------------------------------------------------------------
# Helper: fetch latest asset URL from GitHub
#   $1 = owner/repo , $2 = regex to match asset name
# -----------------------------------------------------------------------------
dl_latest_asset() {
    local repo="$1" pattern="$2"
    gh release view --repo "$repo" --json assets |
        jq -r --arg pat "$pattern" '.assets[] | select(.name | test($pat)) | .url' |
        head -n1
}

# -----------------------------------------------------------------------------
# Installer primitives
# -----------------------------------------------------------------------------
install_pkg() {
  local url="$1" pkg_path="${DOWNLOAD_DIR}/$(basename "$url")"
  [[ -f "$pkg_path" ]] || curl -L -o "$pkg_path" "$url"
  sudo installer -pkg "$pkg_path" -target /
}

install_dmg() {
  local url="$1" filename="${DOWNLOAD_DIR}/$(basename "$url" | sed 's/[^A-Za-z0-9._-]/_/g')"
  [[ -f "$filename" ]] || curl -L -o "$filename" "$url"
  local vol
  vol=$(hdiutil attach "$filename" -nobrowse -quiet | awk '{print $3}')
  local app
  app=$(find "$vol" -maxdepth 1 -name "*.app" -print -quit)
  sudo cp -R "$app" /Applications/
  hdiutil detach "$vol" -quiet
}

install_zip() {
  local url="$1" zip_path="${DOWNLOAD_DIR}/$(basename "$url")"
  [[ -f "$zip_path" ]] || curl -L -o "$zip_path" "$url"
  local tmp
  tmp=$(mktemp -d)
  unzip -q "$zip_path" -d "$tmp"
  local app
  app=$(find "$tmp" -maxdepth 2 -name "*.app" -print -quit)
  sudo cp -R "$app" /Applications/
  rm -rf "$tmp"
}

# -----------------------------------------------------------------------------
# Application installs (bundle IDs for idempotence checks)
# -----------------------------------------------------------------------------

# Google 日本語入力 (.pkg)
if ! mdfind "kMDItemCFBundleIdentifier == 'com.google.inputmethod.Japanese'" | grep -q .; then
  install_pkg "https://dl.google.com/japanese-ime/latest/GoogleJapaneseInput.pkg"
fi

# Karabiner‑Elements (.pkg via GitHub)
if ! mdfind "kMDItemCFBundleIdentifier == 'org.pqrs.Karabiner-EventViewer'" | grep -q .; then
  karabiner_url=$(dl_latest_asset "pqrs-org/Karabiner-Elements" "Karabiner-Elements-.*\\.pkg")
  install_pkg "$karabiner_url"
fi

# iTerm2 (.zip, stable URL)
if ! mdfind "kMDItemCFBundleIdentifier == 'com.googlecode.iterm2'" | grep -q .; then
  install_zip "https://iterm2.com/downloads/stable/iTerm2.zip"
fi

# Obsidian (.dmg via GitHub)
if ! mdfind "kMDItemCFBundleIdentifier == 'md.obsidian'" | grep -q .; then
  obsidian_url=$(dl_latest_asset "obsidianmd/obsidian-releases" "obsidian-.*-universal.dmg")
  install_dmg "$obsidian_url"
fi

# Raycast (.dmg, fixed URL)
if ! mdfind "kMDItemCFBundleIdentifier == 'com.raycast.macos'" | grep -q .; then
  install_dmg "https://releases.raycast.com/Raycast.dmg"
fi

# Arc Browser (.dmg)
if ! mdfind "kMDItemCFBundleIdentifier == 'company.thebrowser.Browser'" | grep -q . && [ ! -d "/Applications/Arc.app" ]; then
  install_dmg "https://arc.net/download"
fi

# Scroll Reverser (.dmg via GitHub)
if ! mdfind "kMDItemCFBundleIdentifier == 'net.pilotmoon.scroll-reverser'" | grep -q .; then
  scroll_url=$(dl_latest_asset "pilotmoon/Scroll-Reverser" "ScrollReverser-.*\\.dmg")
  install_dmg "$scroll_url"
fi

# Slack (.dmg)
if ! mdfind "kMDItemCFBundleIdentifier == 'com.tinyspeck.slackmacgap'" | grep -q .; then
  install_dmg "https://slack.com/ssb/download-osx"
fi

# Discord (.dmg)
if ! mdfind "kMDItemCFBundleIdentifier == 'com.hnc.Discord'" | grep -q .; then
  install_dmg "https://discord.com/api/download?platform=osx"
fi

# WhatsApp Desktop (.dmg universal)
if ! mdfind "kMDItemCFBundleIdentifier == 'com.whatsappdesktop'" | grep -q .; then
  install_dmg "https://web.whatsapp.com/desktop/mac/universal/WhatsApp.dmg"
fi

printf "\n✅ GUI apps installation script completed without mas‑cli.\n"
