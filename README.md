# VSCodium: quiet UI config

> [!IMPORTANT] 
> **Agentically Engineered!**  
> Claude Code was used to create this configuration, install scripts, and documentation

A minimal-chrome, glass-friendly VSCodium setup. Built for Arch + Hyprland and portable to macOS and Windows. It covers the UI only and installs no extensions.

```
User/settings.json        portable UI settings (the main file)
User/keybindings.json     toggles to bring hidden UI back on demand
linux/codium-flags.conf   Electron launch flags (Arch vscodium-bin reads ~/.config/codium-flags.conf)
linux/hypr/vscodium.lua   Hyprland opacity rule
linux/codium-term         Hyprland launcher: opens VSCodium with the terminal panel focused
install.sh                Linux/macOS: symlinks everything, backs up what's there
install.ps1               Windows: symlinks (or copies without Developer Mode)
```

## Install

```sh
./install.sh                 # Linux / macOS
powershell -ExecutionPolicy Bypass -File .\install.ps1   # Windows (stock PowerShell 5.1 or pwsh 7)
```

On Hyprland, add `require("vscodium")` to `~/.config/hypr/hyprland.lua` once.

Files are **symlinked**, so changes made in the Settings UI are written back to this repo.

## What gets removed

| Area | Change |
|---|---|
| Title bar | Native style + `customTitleBarVisibility: never`. Hyprland draws no decorations, so there's no bar at all. macOS and Windows get their normal OS title bar. |
| Menu bar | Hidden until you tap **Alt** |
| Command center, layout controls, browser button | Off |
| Activity bar | Moved into the side bar header (`"hidden"` removes it completely) |
| Secondary side bar / chat | Hidden by default. Built-in AI surfaces disabled. |
| Tabs | Compact height, shrink-to-fit, no × buttons, no split/… actions |
| Breadcrumbs, minimap, sticky scroll, code lens, lightbulb | Off (toggle keys below) |
| Inlay hints | Shown only while you hold **Ctrl+Alt** |
| Terminal | No per-command gutter dots, no "ask AI" hint, tab list only when there are 2+ terminals |
| Startup | No welcome page, walkthroughs, tips or extension recommendations |
| Theme | `Dark 2026`, with every surface set to `#16161a` and all 1px borders set to transparent |

## Toggles

| Keys (Cmd on macOS) | Action |
|---|---|
| Ctrl+K Z | Zen mode |
| Ctrl+B / Ctrl+J | Side bar / panel |
| Ctrl+K Ctrl+M | Minimap |
| Ctrl+K Ctrl+B | Status bar |
| Ctrl+K Ctrl+. | Breadcrumbs |

## Terminal-first launch (Hyprland)

SUPER+SHIFT+N runs `~/.local/bin/codium-term`. It starts VSCodium, waits for the new window, then presses
Ctrl+Alt+Shift+F12, which is bound to `workbench.action.terminal.focus` in `keybindings.json`. That command
opens the terminal panel under the editor and puts the cursor in it. VSCodium has no setting for this, so the
launcher is the extension-free workaround. On macOS/Windows, press the same combo yourself or bind it to something easier.

From that terminal:

| Command | Result |
|---|---|
| `codium file.txt` | Opens in **this** window, in the editor above the terminal |
| `codium some/dir` | Loads the folder into **this** window (the wrapper adds `-r`; the window reloads) |
| `command codium some/dir` | Skips the wrapper: opens a **new** window |
| `codium -r some/dir` | Swaps this window to that folder (reloads the window) |
| `codium -a some/dir` | Adds the folder to this window's workspace |

## Transparency: how it works and its limits

VSCodium (Electron) can't render a transparent background with opaque text without patching its files, which is what the "Vibrancy" extensions do. So transparency here comes from the compositor:

- **Hyprland:** `linux/hypr/vscodium.lua` sets the window to 0.88 opacity when active and 0.80 when inactive, on top of your existing blur. Text fades along with the background, which is why the theme flattens all surfaces to a single colour: the result looks like one pane of glass instead of mismatched greys. To try values live: `hyprctl setprop class:codium opacity 0.9`.
- **macOS / Windows:** there's no compositor rule. The config still gives the flat, borderless look but the window stays opaque. For real translucency there, add an OS-level tool (e.g. a window-opacity utility) or a vibrancy extension later.

## Platform gaps (macOS / Windows)

`settings.json` and `keybindings.json` work everywhere. The Hyprland and zsh extras are Linux-only. None of these gaps are blockers; they're listed here in case they're worth closing later.

| Linux feature | Elsewhere | Possible fix |
|---|---|---|
| Glass transparency (`linux/hypr/vscodium.lua`) | Window is opaque but keeps the flat, borderless look | Third-party window-opacity tool, or a vibrancy extension |
| SUPER+SHIFT+N opens with the terminal focused (`linux/codium-term`) | No launcher: open VSCodium, then press Ctrl+` | OS shortcut tool (AutoHotkey / Raycast) that launches and sends Ctrl+Alt+Shift+F12 |
| `codium file` hides the panel (`shell/vscodium.zsh`) | File opens in the same window; panel stays open | Press Ctrl+J, or script the key press with the same kind of tool |
| `codium folder` reuses the window | Opens a new window | Type `codium -r folder`, or add a PowerShell profile function. On macOS the zsh wrapper only activates under Hyprland, so its folder handling would need moving out of that check |
| `vc` alias | Lives in zsh-starship-setup, so it isn't there on Windows | `Set-Alias vc codium` in `$PROFILE` |
| `codium-flags.conf` | Linux only | Not needed |

Windows install notes: symlinks need Developer Mode or an admin shell, and without either `install.ps1` copies the files instead (re-run it after editing). It targets `%APPDATA%\VSCodium\User`, so the portable zip build, which keeps settings in its own `data` folder, isn't covered. Neither `install.ps1` nor the macOS path of `install.sh` has been tested yet.

The macOS title bar is the native one (traffic lights), and `SF Mono` in the font list only resolves if it's installed system-wide, otherwise Menlo is used.

## Ideas for later passes

- `workbench.editor.showTabs: "single"`: one title instead of a tab strip, navigate with Ctrl+P
- `workbench.activityBar.location: "hidden"` + `workbench.statusBar.visible: false`: editor-only, with everything reached by keyboard
- Generate the colour block from your Noctalia/wallpaper palette so VSCodium matches the shell
- A light-theme pair (`[Light 2026]` overrides) with `window.autoDetectColorScheme`
- Extensions: Custom CSS / Vibrancy for true background-only transparency, a theme, an icon theme
- Hide the VSCodium logo on empty editors: Custom CSS `.letterpress { display: none }`. No setting exists for it, and swapping `out/media/letterpress-*.svg` needs root and comes back with every update
