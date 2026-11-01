#!/usr/bin/env bash
# Symlink this repo's VSCodium config into place (Linux + macOS).
# Existing files are moved aside to <name>.bak.<timestamp>, never deleted.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
stamp="$(date +%Y%m%d-%H%M%S)"

case "$(uname -s)" in
    Linux)  user_dir="${XDG_CONFIG_HOME:-$HOME/.config}/VSCodium/User" ;;
    Darwin) user_dir="$HOME/Library/Application Support/VSCodium/User" ;;
    *) echo "Unsupported OS — use install.ps1 on Windows." >&2; exit 1 ;;
esac

link() {  # link <source> <target>
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
        echo "ok      $dst"; return
    fi
    if [[ -e "$dst" || -L "$dst" ]]; then
        mv "$dst" "$dst.bak.$stamp"
        echo "backup  $dst -> $dst.bak.$stamp"
    fi
    ln -s "$src" "$dst"
    echo "linked  $dst"
}

link "$repo/User/settings.json"    "$user_dir/settings.json"
link "$repo/User/keybindings.json" "$user_dir/keybindings.json"

if [[ "$(uname -s)" == Linux ]]; then
    link "$repo/linux/codium-flags.conf" "${XDG_CONFIG_HOME:-$HOME/.config}/codium-flags.conf"
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        link "$repo/linux/hypr/vscodium.lua" "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/vscodium.lua"
        link "$repo/linux/codium-term"       "$HOME/.local/bin/codium-term"
        if [[ -d "$HOME/.oh-my-zsh/custom" ]]; then
            link "$repo/shell/vscodium.zsh" "$HOME/.oh-my-zsh/custom/vscodium.zsh"
        fi
        echo
        echo "Hyprland: add this line to hyprland.lua (once) to load the window rule:"
        echo '    require("vscodium")'
    fi
fi

echo
echo "Done. Restart VSCodium to pick up launch flags."
