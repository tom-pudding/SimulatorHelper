import Foundation

struct StatusBarCommandService: Sendable {
    private let processRunner: any ProcessRunning

    init(processRunner: any ProcessRunning = SystemProcessRunner()) {
        self.processRunner = processRunner
    }

    func apply(
        configuration: StatusBarConfiguration,
        capabilities: StatusBarCapabilities,
        to simulator: SimulatorDescriptor
    ) async throws {
        let arguments = try buildOverrideArguments(
            configuration: configuration,
            capabilities: capabilities,
            simulatorID: simulator.udid
        )

        let result = try await processRunner.run(
            ProcessRequest(
                executableURL: URL(fileURLWithPath: "/usr/bin/xcrun"),
                arguments: arguments
            )
        )

        guard result.isSuccess else {
            throw StatusBarCommandError.commandFailed(result.combinedOutput)
        }
    }

    func clear(on simulator: SimulatorDescriptor) async throws {
        let result = try await processRunner.run(
            ProcessRequest(
                executableURL: URL(fileURLWithPath: "/usr/bin/xcrun"),
                arguments: ["simctl", "status_bar", simulator.udid, "clear"]
            )
        )

        guard result.isSuccess else {
            throw StatusBarCommandError.commandFailed(result.combinedOutput)
        }
    }

    func buildOverrideArguments(
        configuration: StatusBarConfiguration,
        capabilities: StatusBarCapabilities,
        simulatorID: String
    ) throws -> [String] {
        try validate(configuration: configuration, capabilities: capabilities)

        return [
            "simctl", "status_bar", simulatorID, "override",
            "--time", configuration.timeString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
            "--dataNetwork", configuration.dataNetwork.rawValue,
            "--wifiMode", configuration.wifiMode.rawValue,
            "--wifiBars", String(configuration.wifiBars),
            "--cellularMode", configuration.cellularMode.rawValue,
            "--cellularBars", String(configuration.cellularBars),
            "--batteryState", configuration.batteryState.rawValue,
            "--batteryLevel", String(configuration.batteryLevel),
        ]
    }

    private func validate(configuration: StatusBarConfiguration, capabilities: StatusBarCapabilities) throws {
        guard !configuration.timeString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            throw StatusBarCommandError.validationFailed("Time is required.")
        }

        let requiredFlags: [StatusBarCapabilities.Flag] = [
            .time,
            .dataNetwork,
            .wifiMode,
            .wifiBars,
            .cellularMode,
            .cellularBars,
            .batteryState,
            .batteryLevel,
        ]

        for flag in requiredFlags where !capabilities.supportedFlags.contains(flag) {
            throw StatusBarCommandError.validationFailed("The active toolchain does not support the \(flag.rawValue) status bar option.")
        }

        guard capabilities.supportedDataNetworks.contains(configuration.dataNetwork.rawValue) else {
            throw StatusBarCommandError.validationFailed("The selected network type is not supported by the active toolchain.")
        }

        guard capabilities.supportedWiFiModes.contains(configuration.wifiMode.rawValue) else {
            throw StatusBarCommandError.validationFailed("The selected Wi-Fi mode is not supported by the active toolchain.")
        }

        guard capabilities.supportedCellularModes.contains(configuration.cellularMode.rawValue) else {
            throw StatusBarCommandError.validationFailed("The selected cellular mode is not supported by the active toolchain.")
        }

        guard capabilities.supportedBatteryStates.contains(configuration.batteryState.rawValue) else {
            throw StatusBarCommandError.validationFailed("The selected battery state is not supported by the active toolchain.")
        }

        guard capabilities.wifiBarsRange.contains(configuration.wifiBars) else {
            throw StatusBarCommandError.validationFailed("Wi-Fi bars must stay within \(capabilities.wifiBarsRange.lowerBound)-\(capabilities.wifiBarsRange.upperBound).")
        }

        guard capabilities.cellularBarsRange.contains(configuration.cellularBars) else {
            throw StatusBarCommandError.validationFailed("Cellular bars must stay within \(capabilities.cellularBarsRange.lowerBound)-\(capabilities.cellularBarsRange.upperBound).")
        }

        guard capabilities.batteryLevelRange.contains(configuration.batteryLevel) else {
            throw StatusBarCommandError.validationFailed("Battery level must stay within \(capabilities.batteryLevelRange.lowerBound)-\(capabilities.batteryLevelRange.upperBound).")
        }
    }
}

enum StatusBarCommandError: LocalizedError {
    case validationFailed(String)
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case let .validationFailed(message):
            return message
        case let .commandFailed(message):
            return "Failed to update the simulator status bar. \(message)"
        }
    }
}
