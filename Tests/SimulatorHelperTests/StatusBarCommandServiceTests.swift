import Foundation
import Testing
@testable import SimulatorHelper

struct StatusBarCommandServiceTests {
    @Test
    func buildsExpectedOverrideArguments() throws {
        let arguments = try StatusBarCommandService().buildOverrideArguments(
            configuration: .defaultMVP,
            capabilities: sampleCapabilities,
            simulatorID: sampleSimulator.udid
        )

        #expect(arguments == [
            "simctl", "status_bar", sampleSimulator.udid, "override",
            "--time", "9:41",
            "--batteryState", "charged",
            "--batteryLevel", "100",
        ])
    }

    @Test
    func usesHoursAndMinutesFromTimeOverride() throws {
        var configuration = StatusBarConfiguration.defaultMVP
        configuration.timeOverride = Calendar(identifier: .gregorian).date(
            from: DateComponents(year: 2026, month: 6, day: 1, hour: 10, minute: 27, second: 0)
        )!

        let arguments = try StatusBarCommandService().buildOverrideArguments(
            configuration: configuration,
            capabilities: sampleCapabilities,
            simulatorID: sampleSimulator.udid
        )

        #expect(arguments[5] == "10:27")
    }

    @Test
    func convertsTopOfHourAndMidnightTimesToOverflowFormForSimctl() {
        // iOS 26 simctl rejects literal ":00" minutes and literal hour "0".
        // The overflow form must normalize to the same wall-clock time on-device.
        #expect(StatusBarConfiguration.simctlTimeArgument(hour: 9, minute: 41) == "9:41")
        #expect(StatusBarConfiguration.simctlTimeArgument(hour: 13, minute: 5) == "13:05")
        #expect(StatusBarConfiguration.simctlTimeArgument(hour: 11, minute: 0) == "10:60")
        #expect(StatusBarConfiguration.simctlTimeArgument(hour: 12, minute: 0) == "11:60")
        #expect(StatusBarConfiguration.simctlTimeArgument(hour: 23, minute: 0) == "22:60")
        #expect(StatusBarConfiguration.simctlTimeArgument(hour: 1, minute: 0) == "23:120")
        #expect(StatusBarConfiguration.simctlTimeArgument(hour: 0, minute: 0) == "22:120")
        #expect(StatusBarConfiguration.simctlTimeArgument(hour: 0, minute: 30) == "22:150")
    }

    @Test
    func usesDischargingBatteryStateBelowOneHundredPercent() throws {
        var configuration = StatusBarConfiguration.defaultMVP
        configuration.batteryLevel = 80

        let arguments = try StatusBarCommandService().buildOverrideArguments(
            configuration: configuration,
            capabilities: sampleCapabilities,
            simulatorID: sampleSimulator.udid
        )

        #expect(arguments[7] == "discharging")
    }

    @Test
    func rejectsUnsupportedBatteryStateSupport() {
        let limitedCapabilities = StatusBarCapabilities(
            supportedFlags: [.time, .batteryState, .batteryLevel],
            supportedDataNetworks: [],
            supportedWiFiModes: [],
            supportedCellularModes: [],
            supportedBatteryStates: ["charged"],
            wifiBarsRange: sampleCapabilities.wifiBarsRange,
            cellularBarsRange: sampleCapabilities.cellularBarsRange,
            batteryLevelRange: sampleCapabilities.batteryLevelRange
        )

        var configuration = StatusBarConfiguration.defaultMVP
        configuration.batteryLevel = 80

        #expect(throws: StatusBarCommandError.self) {
            _ = try StatusBarCommandService().buildOverrideArguments(
                configuration: configuration,
                capabilities: limitedCapabilities,
                simulatorID: sampleSimulator.udid
            )
        }
    }
}

private let sampleCapabilities = StatusBarCapabilities(
    supportedFlags: [.time, .batteryState, .batteryLevel, .operatorName],
    supportedDataNetworks: [],
    supportedWiFiModes: [],
    supportedCellularModes: [],
    supportedBatteryStates: ["charging", "charged", "discharging"],
    wifiBarsRange: 0...3,
    cellularBarsRange: 0...4,
    batteryLevelRange: 0...100
)

private let sampleSimulator = SimulatorDescriptor(
    udid: "38C2AD9E-9318-445C-95CC-AAC69492FC2D",
    name: "iPhone 17 Pro",
    runtimeIdentifier: "com.apple.CoreSimulator.SimRuntime.iOS-26-3",
    runtimeName: "iOS 26.3",
    deviceTypeIdentifier: "com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro",
    productFamily: .iPhone,
    state: "Booted",
    lastBootedAt: ISO8601DateFormatter().date(from: "2026-05-31T12:39:20Z")
)
