# Simulator Helper

Simulator Helper is a native macOS SwiftUI utility for configuring iOS Simulator status bar settings and capturing screenshots without using Terminal.

## Current Status

Phase 1 is complete.

Implemented so far:
- macOS SwiftUI app scaffold
- MVVM-oriented source layout
- shared `ProcessRunner`
- `EnvironmentService` for Xcode and `simctl` readiness checks
- environment banner and toolchain details UI
- unit tests for the environment layer

Planned next:
- Phase 2: booted simulator discovery and selection
- Phase 3: status bar controls and apply/clear
- Phase 4: screenshot workflow

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
