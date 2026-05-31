# Simulator Helper Handoff

## Current Status

Completed:
- Phase 1 from `TASKS.md`
- Phase 2 from `TASKS.md`
- Phase 3 from `TASKS.md`

Not started:
- Phase 4 screenshot workflow
- Phase 5 final verification and polish

## What Phase 1 Added

- Swift package-backed macOS SwiftUI app scaffold
- MVVM-oriented directory structure
- `SystemProcessRunner` for shell command execution
- `EnvironmentService` that checks:
  - `xcodebuild -version`
  - `xcode-select -p`
  - `xcrun --find simctl`
  - `xcrun simctl help status_bar`
- initial UI showing environment readiness and toolchain details
- environment-layer tests using a stubbed process runner

## What Phase 2 Added

- `SimulatorInventoryService` backed by `xcrun simctl list devices --json`
- filtering for booted iPhone and iPad simulators only
- stable sorting for returned simulators
- sidebar selection state for one active simulator
- manual simulator refresh action
- selected-simulator detail card in the main panel
- simulator inventory tests using stubbed JSON

## What Phase 3 Added

- `StatusBarCapabilitiesService` that parses `xcrun simctl help status_bar`
- `StatusBarCapabilities` and `StatusBarConfiguration` models
- validated `StatusBarCommandService` for apply and clear operations
- MVP status bar form UI for:
  - time
  - network type
  - Wi-Fi mode and bars
  - cellular mode and bars
  - battery state and level
- status bar capability and command tests

## Build and Test

Use:

```bash
swift build
swift test
```

In this Codex environment, build and test commands require execution outside the default sandbox.

## Next Recommended Step

Start Phase 4 from `TASKS.md`:

1. add folder picker flow
2. persist the chosen folder
3. generate the screenshot filename
4. implement `simctl io screenshot`
5. show success and failure messages clearly

## Notes

- The app currently uses a Swift package executable with a SwiftUI `App` entry point.
- Capability detection remains aligned with the approved architecture: trust the installed toolchain at runtime instead of assuming a fixed Xcode feature matrix.
