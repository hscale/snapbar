# Changelog

## [0.2.0] - 2026-03-23
### added
- app icon: blue gradient background with monitor + crosshair + dashed selection handles (appicon.icns)
- launch at login toggle in menu bar extra via smappservice (macos 13+)
- cfbundleiconfile set in info.plist so finder displays the icon

### changed
- rebranded: sources/faststonex/ → sources/snapbar/, faststonexapp.swift → snapbarapp.swift
- renamed faststone x.entitlements → snapbar.entitlements
- build script now copies appicon.icns and links -framework servicemanagement

### fixed
- app showed macos generic placeholder icon (no icns file, empty resources folder)
- /applications/ copy had empty contents/resources/ directory

## [0.1.0] - 2026-03-22
### added
- initial floating toolbar with screen, region, options, hide buttons
- menu bar extra with same shortcuts
- draggable panel with position persistence
- accessibility permission prompt on first launch
