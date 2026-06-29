# Mouse DPI OSD

On-screen DPI indicator for **generic gaming mice** that have no manufacturer software (OEM / Yichip / white-label). Shows your current DPI in the corner and a center popup when you press the DPI button.

Built for Windows 10/11. Uses [AutoHotkey v2](https://www.autohotkey.com/).

## Features

- **Corner HUD** — transparent text overlay (current DPI)
- **Center popup** — compact semi-transparent pill when DPI changes
- **System tray** — hover for current DPI, test popup, button finder
- **Persists settings** — remembers last DPI step across reboots
- **Safe hotkeys** — never hooks left/right click (normal mouse use stays intact)

## Who is this for?

| Works well | Limited |
|------------|---------|
| Generic USB/wireless mice with DPI button | Logitech / Razer / SteelSeries (use their official apps instead) |
| Yichip `VID_3151` and similar OEM chips | Mice where DPI button is **hardware-only** (no Windows signal) |

If your DPI button does not send any event to Windows, no software can auto-detect it — this tool tracks **configured DPI steps** when a detectable side button is pressed.

## Quick install

### Option A — One-click (PowerShell, Admin)

```powershell
git clone https://github.com/Hesamsamani/mouse-dpi-osd.git
cd mouse-dpi-osd
powershell -ExecutionPolicy Bypass -File .\Install-Mouse-DPI-OSD.ps1
```

### Option B — Manual

1. Install **AutoHotkey v2**
2. Copy `dpi-osd-config.ini.example` → `dpi-osd-config.ini`
3. Double-click `Mouse-DPI-OSD.ahk`
4. Optional: run `Install-Mouse-DPI-OSD.ps1` as Administrator for startup + logon task

## First-time setup

1. Run **Mouse DPI OSD** (tray icon appears)
2. Tray menu → **Button finder** → press your **DPI button** once  
   - If detected (e.g. `XButton1`), restart OSD from tray  
   - If nothing appears, DPI is hardware-only — set `DpiIndex` manually in config
3. Edit `dpi-osd-config.ini`:
   - `DpiSteps` — match your mouse’s DPI levels
   - `DpiIndex` — which step you start on (1-based)

## Configuration

| Setting | Description |
|---------|-------------|
| `DpiSteps` | Comma-separated DPI values your mouse cycles through |
| `DpiIndex` | Current step (1 = first value in `DpiSteps`) |
| `DpiHotkeys` | Buttons that cycle DPI (`XButton1`, `XButton2`, `MButton`) |
| `PopupMs` | How long the center popup stays (ms) |
| `AlwaysShowHud` | `true` = corner HUD always visible |

**Never** add `LButton` or `RButton` to `DpiHotkeys` — it will break normal clicking.

## Tray menu

- **Test popup** — preview the center notification
- **Button finder** — map your DPI / side button
- **Edit settings** — open `dpi-osd-config.ini`
- **Exit** — stop the overlay

## Requirements

- Windows 10 or 11
- [AutoHotkey v2](https://www.autohotkey.com/) (installer script can install via winget)

## License

MIT — see [LICENSE](LICENSE).

## Author

[Hesam Samani](https://github.com/Hesamsamani) — part of a broader PC gaming optimization toolkit.