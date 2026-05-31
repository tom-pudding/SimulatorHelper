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
    supportedDataNetworks: ["wifi", "3g", "4g", "lte", "5g"],
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
