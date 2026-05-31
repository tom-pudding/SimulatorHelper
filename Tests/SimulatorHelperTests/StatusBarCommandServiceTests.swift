import Foundation
import Testing
@testable import SimulatorHelper

struct StatusBarCommandServiceTests {
    @Test
    func buildsExpectedOverrideArguments() throws {
        let service = StatusBarCommandService()
        let arguments = try service.buildOverrideArguments(
            configuration: .defaultMVP,
            capabilities: sampleCapabilities,
            simulatorID: sampleSimulator.udid
        )

        #expect(arguments == [
            "simctl", "status_bar", sampleSimulator.udid, "override",
            "--time", "9:41",
            "--dataNetwork", "wifi",
            "--wifiMode", "active",
            "--wifiBars", "3",
            "--cellularMode", "active",
            "--cellularBars", "4",
            "--batteryState", "charged",
            "--batteryLevel", "100",
        ])
    }

    @Test
    func preservesCustomTimeStrings() throws {
        var configuration = StatusBarConfiguration.defaultMVP
        configuration.timeString = "10:27"

        let arguments = try StatusBarCommandService().buildOverrideArguments(
            configuration: configuration,
            capabilities: sampleCapabilities,
            simulatorID: sampleSimulator.udid
        )

        #expect(arguments[5] == "10:27")
    }

    @Test
    func buildsLocalISODateAndTimeOverrideArguments() throws {
        var configuration = StatusBarConfiguration.defaultMVP
        configuration.timeOverrideMode = .dateAndTime
        configuration.dateAndTimeOverride = Calendar(identifier: .gregorian).date(
            from: DateComponents(year: 2026, month: 6, day: 1, hour: 9, minute: 41, second: 0)
        )!

        let arguments = try StatusBarCommandService().buildOverrideArguments(
            configuration: configuration,
            capabilities: sampleCapabilities,
            simulatorID: sampleSimulator.udid
        )

        #expect(arguments[5] == "2026-06-01T09:41:00")
    }

    @Test
    func acceptsAdvancedRuntimeNetworkSelections() throws {
        var configuration = StatusBarConfiguration.defaultMVP
        configuration.dataNetwork = .fiveGUWB

        let arguments = try StatusBarCommandService().buildOverrideArguments(
            configuration: configuration,
            capabilities: sampleCapabilities,
            simulatorID: sampleSimulator.udid
        )

        #expect(arguments[7] == "5g-uwb")
    }

    @Test
    func rejectsUnsupportedNetworkSelections() {
        var configuration = StatusBarConfiguration.defaultMVP
        configuration.dataNetwork = .fiveG

        let limitedCapabilities = StatusBarCapabilities(
            supportedFlags: sampleCapabilities.supportedFlags,
            supportedDataNetworks: ["wifi", "3g", "4g", "lte"],
            supportedWiFiModes: sampleCapabilities.supportedWiFiModes,
            supportedCellularModes: sampleCapabilities.supportedCellularModes,
            supportedBatteryStates: sampleCapabilities.supportedBatteryStates,
            wifiBarsRange: sampleCapabilities.wifiBarsRange,
            cellularBarsRange: sampleCapabilities.cellularBarsRange,
            batteryLevelRange: sampleCapabilities.batteryLevelRange
        )

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
    supportedFlags: [.time, .dataNetwork, .wifiMode, .wifiBars, .cellularMode, .cellularBars, .batteryState, .batteryLevel, .operatorName],
    supportedDataNetworks: ["hide", "wifi", "3g", "4g", "lte", "lte-a", "lte+", "5g", "5g+", "5g-uwb", "5g-uc"],
    supportedWiFiModes: ["searching", "failed", "active"],
    supportedCellularModes: ["notSupported", "searching", "failed", "active"],
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
