# Simulator Helper

Simulator Helper is a native macOS SwiftUI utility for configuring iOS Simulator status bar settings and capturing screenshots without using Terminal.

## Current Status

MVP implementation is complete.

Implemented so far:
- macOS SwiftUI app scaffold
- MVVM-oriented source layout
- shared `ProcessRunner`
- `EnvironmentService` for Xcode and `simctl` readiness checks
- environment banner and toolchain details UI
- booted iPhone and iPad simulator discovery
- simulator sidebar with single selection
- manual simulator refresh
- status bar capability detection from the active `simctl`
- validated MVP status bar form and apply/clear actions
- screenshot folder persistence with a default Desktop destination
- screenshot filename generation and capture command wiring
- unit tests for environment, inventory, status bar, screenshot, and settings services

Known MVP limitations:
- detects booted simulators only
- single simulator selection only
- no carrier name editing
- no advanced network variants beyond the curated MVP set
- no open-save-folder action yet
- no presets or batch capture yet

Next version candidates:
- carrier name editing
- advanced network variants
- open save folder
- persisted last-used status bar values
- optional auto-refresh

## Requirements

- macOS 15.0+
- Xcode 26.x recommended

## Build

```bash
swift build
```

## Run

```bash
swift run
```

The package can also be opened directly in Xcode.

## Test

```bash
swift test
```

## Project Layout

```text
Sources/SimulatorHelper/
  App/
  Models/
  Services/
  ViewModels/
  Views/

Tests/SimulatorHelperTests/
```
