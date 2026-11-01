# VSCodium integrated-terminal helpers (zsh). Linked into $ZSH_CUSTOM by install.sh.
# Only active inside VSCodium's own terminal on Hyprland; everywhere else `codium` is untouched.

if [[ "$TERM_PROGRAM" == vscode && -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    # `codium <file>…` from the terminal panel: open the file(s) in this window, then hide the
    # panel so the editor gets the full height. Ctrl+` brings the terminal back.
    # `codium <folder>`: load the folder into this window too (-r) instead of a new window.
    #   The window reloads, so this terminal restarts. If a folder was already open, it's replaced;
    #   use `command codium <folder>` when you do want a separate window.
    # Flags (-n, -g file:line, …) and bare `codium` pass straight through.
    function codium {   # `function` form: still defines cleanly if someone aliases codium
        local arg
        (( $# == 0 )) && { command codium; return }
        for arg in "$@"; do
            [[ "$arg" == -* ]] && { command codium "$@"; return }
        done
        for arg in "$@"; do
            [[ -d "$arg" ]] && { command codium -r "$@"; return }
        done
        command codium "$@" || return
        sleep 0.3   # let the editor open before the panel goes away
        # Ctrl+Alt+Shift+F11 is bound to workbench.action.closePanel in keybindings.json
        hyprctl eval 'hl.dispatch(hl.dsp.send_key_state({ mods = "CTRL ALT SHIFT", key = "F11", state = "down" }))' >/dev/null
        hyprctl eval 'hl.dispatch(hl.dsp.send_key_state({ mods = "CTRL ALT SHIFT", key = "F11", state = "up" }))' >/dev/null
    }
fi
