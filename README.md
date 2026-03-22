# SnapBar

A minimal floating toolbar for macOS that puts your screenshot shortcuts one click away.

![macOS 26+](https://img.shields.io/badge/macOS-26%2B-blue) ![Swift](https://img.shields.io/badge/Swift-6-orange) ![License](https://img.shields.io/badge/license-MIT-green)

## What it does

SnapBar lives as a small floating pill on your screen. Click a button and it fires the corresponding keyboard shortcut to your screenshot app (FastStone Capture or any other tool). Drag it anywhere — position is remembered across restarts.

| Button | Shortcut sent | Purpose |
|--------|--------------|---------|
| Screen | `⌘⇧T` | Full-screen capture |
| Region | `⌘⇧Y` | Region / window capture |
| Options | `⌘⇧I` | Screenshot options |
| Hide | — | Collapse the toolbar |

A menu bar icon provides the same actions when the toolbar is hidden.

## Requirements

- macOS 26.0 or later
- Xcode Command Line Tools (`xcode-select --install`)

## Build

```bash
git clone https://github.com/hscale/snapbar.git
cd snapbar
bash scripts/build-app.sh
open SnapBar.app
```

On first launch macOS will prompt for **Accessibility** permission — this is required so SnapBar can send keyboard events to other apps.

> If the prompt doesn't appear: **System Settings → Privacy & Security → Accessibility → enable SnapBar**

## Positioning

Drag the grip handle (⠿) on the left of the toolbar to move it. The position is saved automatically and restored on next launch.

## Project structure

```
Sources/FastStoneX/
  FastStoneXApp.swift   # App entry point, menu bar extra
  ToolbarPanel.swift    # Floating NSPanel, position persistence
  ToolbarView.swift     # SwiftUI toolbar UI, keyboard event dispatch
Resources/
  screen.svg            # Full-screen icon
  region.svg            # Region-select icon
  options.svg           # Options / viewfinder icon
  hide.svg              # Hide toolbar icon
scripts/
  build-app.sh          # Single-command build script
Info.plist
FastStoneX.entitlements
```

## How it works

1. The toolbar is a borderless `NSPanel` at `.floating` window level — it stays above all app windows without stealing focus.
2. When a button is pressed, the panel hides briefly (150 ms), fires a `CGEvent` keyboard pair via `.cghidEventTap`, then reappears. This ensures the target app receives the shortcut while the toolbar is out of the way.
3. `AXIsProcessTrusted()` is checked before every dispatch. If Accessibility permission is missing the system prompt is re-triggered instead of silently failing.

## Customizing shortcuts

Edit the `CGKeyCode` values in `ToolbarView.swift → postShortcut(key:)` calls:

```swift
SnapButton(svg: "screen",  label: "Screen")  { postShortcut(key: 20) }
SnapButton(svg: "region",  label: "Region")  { postShortcut(key: 21) }
SnapButton(svg: "options", label: "Options") { postShortcut(key: 23) }
```

Key codes follow the standard macOS virtual key table (e.g. `0` = A, `1` = S, `20` = T).

## License

MIT
