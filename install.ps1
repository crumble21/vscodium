# Link this repo's VSCodium config into place (Windows).
# Symlinks need Developer Mode enabled or an elevated shell; otherwise files are copied.
# Existing files are moved aside to <name>.bak.<timestamp>, never deleted.
$ErrorActionPreference = 'Stop'

$repo    = $PSScriptRoot
$userDir = Join-Path $env:APPDATA 'VSCodium\User'
$stamp   = Get-Date -Format 'yyyyMMdd-HHmmss'
New-Item -ItemType Directory -Force -Path $userDir | Out-Null

foreach ($name in 'settings.json', 'keybindings.json') {
    $src = Join-Path $repo "User\$name"
    $dst = Join-Path $userDir $name

    $item = Get-Item $dst -ErrorAction SilentlyContinue
    if ($item -and $item.LinkType -eq 'SymbolicLink' -and $item.Target -eq $src) {
        Write-Host "ok      $dst"; continue
    }
    if ($item) {
        Move-Item $dst "$dst.bak.$stamp"
        Write-Host "backup  $dst -> $dst.bak.$stamp"
    }
    try {
        New-Item -ItemType SymbolicLink -Path $dst -Target $src | Out-Null
        Write-Host "linked  $dst"
    } catch {
        Copy-Item $src $dst
        Write-Host "copied  $dst  (no symlink permission; re-run after edits, or enable Developer Mode)"
    }
}
Write-Host "`nDone. Restart VSCodium."
