# Simulator Helper

A native macOS utility that lets you set the iOS Simulator status bar (time and battery) and capture screenshots — no Terminal required.

---

## Download

**[→ Download the latest release](https://github.com/tom-pudding/SimulatorHelper/releases/latest)**

Unzip and move `SimulatorHelper.app` to your Applications folder. Xcode must be installed (the app uses `xcrun simctl` internally), but Xcode does not need to be open.

**Requirements:** macOS 15.0+, Xcode installed

---

## What it does

When preparing App Store screenshots you need a clean, consistent status bar — correct time, full battery. Doing this by hand with `xcrun simctl status_bar` every time is tedious. Simulator Helper gives you a simple GUI to set it once and capture.

- Detects all booted iPhone and iPad simulators automatically
- Sets the status bar time to any value (e.g. 9:41)
- Sets battery level (0–100 %)
- Captures a screenshot to a folder of your choice
- Persists your last-used settings between launches

---

## Build from source

```bash
git clone https://github.com/tom-pudding/SimulatorHelper.git
cd SimulatorHelper
./scripts/install_app.sh
```

This builds a release binary, assembles the `.app` bundle, and copies it to `~/Applications/SimulatorHelper.app`.

```bash
# Run tests
swift test
```

---

## iOS 26 compatibility notes

Developing this app against the iOS 26 beta exposed two `simctl` bugs that required creative workarounds. They are documented here in case you hit them too.

### Bug 1 — Date overrides are completely broken

`simctl status_bar override --time` accepts an ISO 8601 date-time string on older iOS versions to also set the *date* shown in the iPad status bar. On iOS 26 every date-carrying format is rejected:

```
Invalid, non-ISO date/time string
```

Tested and confirmed broken: `2026-06-01T09:41:00+09:00`, `2026-06-01T09:41:00Z`, `2026-06-01T09:41:00`, and every variant with or without milliseconds, timezone offset, or seconds. No workaround was found.

**Status:** date override is not exposed in the UI on iOS 26 simulators.

### Bug 2 — Times ending in :00 and times in the midnight hour are rejected

Any time whose *minute value is zero* (e.g. `11:00`, `9:00`, `0:00`) or whose *hour value is zero* (e.g. `0:30`) is rejected with the same error, even though these are perfectly valid time strings.

Every alternative format was tested — `11:00:00`, `11:00 AM`, `1100`, full-width characters — all rejected.

**Workaround: minute overflow**

`simctl` accepts minute values ≥ 60 and normalises them on the device. Sending `10:60` causes the simulator to display `11:00`.

```
Display  →  Sent to simctl
 11:00   →  10:60
 12:00   →  11:60
  1:00   →  23:120
  0:00   →  22:120
  0:30   →  22:150
  9:41   →  9:41   (unchanged)
```

The conversion lives in `StatusBarConfiguration.simctlTimeArgument`. The UI always shows the human-readable form; only the value sent to `simctl` is rewritten. If a future `simctl` update also rejects overflow minutes, the fix is to remove `simctlTimeArgument` and send the display string directly.

---

## Project layout

```
Sources/SimulatorHelper/
  App/             entry point
  Models/          data structures
  Services/        simctl wrappers, screenshot, settings
  ViewModels/      AppViewModel (@Observable)
  Views/           SwiftUI views

Tests/SimulatorHelperTests/
scripts/
  build_app.sh        assemble .app bundle
  install_app.sh      build + install to ~/Applications
  generate_icon.swift regenerate AppIcon.icns
```

---

## License

MIT
