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
            "--time", configuration.simctlTimeArgument,
            "--batteryState", configuration.resolvedBatteryState.rawValue,
            "--batteryLevel", String(configuration.batteryLevel),
        ]
    }

    private func validate(configuration: StatusBarConfiguration, capabilities: StatusBarCapabilities) throws {
        let requiredFlags: [StatusBarCapabilities.Flag] = [
            .time,
            .batteryState,
            .batteryLevel,
        ]

        for flag in requiredFlags where !capabilities.supportedFlags.contains(flag) {
            throw StatusBarCommandError.validationFailed("The active toolchain does not support the \(flag.rawValue) status bar option.")
        }

        guard capabilities.supportedBatteryStates.contains(configuration.resolvedBatteryState.rawValue) else {
            throw StatusBarCommandError.validationFailed("The active toolchain does not support the required battery state override.")
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
