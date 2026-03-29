#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOME_DIR="${HOME:-}"

log() {
  printf '==> %s\n' "$*"
}

remove_path() {
  local path="$1"
  if [[ -e "$path" || -L "$path" ]]; then
    rm -rf "$path"
    log "Removed: $path"
  fi
}

filter_file() {
  local file="$1"
  local pattern="$2"
  [[ -f "$file" ]] || return 0

  local tmp
  tmp="$(mktemp)"
  grep -Ev "$pattern" "$file" > "$tmp" || true
  mv "$tmp" "$file"
  log "Cleaned: $file"
}

clean_fish_user_paths() {
  command -v fish >/dev/null 2>&1 || return 0

  fish -ic '
    set -l sdk_prefix "$HOME/.sdkman"
    set -l keep
    for p in $fish_user_paths
      if test "$p" = "$sdk_prefix"
        continue
      end
      if string match -q "$sdk_prefix/*" -- $p
        continue
      end
      set -a keep $p
    end
    set -U fish_user_paths $keep
  ' >/dev/null 2>&1 || true
  log "Cleaned fish_user_paths"
}

log "Removing SDKMAN from home"
remove_path "$HOME_DIR/.sdkman"
remove_path "$HOME_DIR/.config/fisher/github.com/reitzig/sdkman-for-fish"
remove_path "$HOME_DIR/.config/fish/conf.d/sdk.fish"
remove_path "$HOME_DIR/.config/fish/conf.d/sdk.fish.bak"
remove_path "$HOME_DIR/.config/fish/conf.d/java.fish"
remove_path "$HOME_DIR/.config/fish/completions/sdk.fish"
remove_path "$HOME_DIR/.config/fish/functions/sdk.fish"
remove_path "$HOME_DIR/.config/fish/functions/__fish_sdkman_lazy_init.fish"
remove_path "$HOME_DIR/.config/fish/functions/__fish_sdkman_run_in_bash.fish"
remove_path "$HOME_DIR/.config/fish/functions/__fish_sdkman_register_shims.fish"
remove_path "$HOME_DIR/.m2/toolchains.xml"
filter_file "$HOME_DIR/.config/fish/fish_plugins" 'sdkman-for-fish'
filter_file "$HOME_DIR/.bashrc" 'sdkman|SDKMAN'
filter_file "$HOME_DIR/.bash_profile" 'sdkman|SDKMAN'
clean_fish_user_paths

log "Removing leftover repo-local SDKMAN / Java files"
remove_path "$REPO_ROOT/.sdkman"
remove_path "$REPO_ROOT/.config/fish/conf.d/sdk.fish.bak"
remove_path "$REPO_ROOT/.config/fish/conf.d/java.fish"
remove_path "$REPO_ROOT/.m2/toolchains.xml"

log "Done. Restart your shell / terminal to fully unload old SDKMAN state."
