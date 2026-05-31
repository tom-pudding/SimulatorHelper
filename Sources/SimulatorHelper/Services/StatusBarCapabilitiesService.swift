import Foundation

struct StatusBarCapabilitiesService: Sendable {
    private let processRunner: any ProcessRunning

    init(processRunner: any ProcessRunning = SystemProcessRunner()) {
        self.processRunner = processRunner
    }

    func loadCapabilities() async throws -> StatusBarCapabilities {
        let result = try await processRunner.run(
            ProcessRequest(
                executableURL: URL(fileURLWithPath: "/usr/bin/xcrun"),
                arguments: ["simctl", "help", "status_bar"]
            )
        )

        guard result.isSuccess else {
            throw StatusBarCapabilitiesError.commandFailed(result.combinedOutput)
        }

        return try parseCapabilities(from: result.combinedOutput)
    }

    func parseCapabilities(from helpOutput: String) throws -> StatusBarCapabilities {
        var capabilities = StatusBarCapabilities.empty
        let lines = helpOutput.split(whereSeparator: { $0.isNewline }).map(String.init)
        var currentFlag: StatusBarCapabilities.Flag?

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

            if trimmedLine.hasPrefix("--time ") {
                capabilities.supportedFlags.insert(.time)
                currentFlag = .time
            } else if trimmedLine.hasPrefix("--dataNetwork ") {
                capabilities.supportedFlags.insert(.dataNetwork)
                currentFlag = .dataNetwork
            } else if trimmedLine.hasPrefix("--wifiMode ") {
                capabilities.supportedFlags.insert(.wifiMode)
                currentFlag = .wifiMode
            } else if trimmedLine.hasPrefix("--wifiBars ") {
                capabilities.supportedFlags.insert(.wifiBars)
                currentFlag = .wifiBars
            } else if trimmedLine.hasPrefix("--cellularMode ") {
                capabilities.supportedFlags.insert(.cellularMode)
                currentFlag = .cellularMode
            } else if trimmedLine.hasPrefix("--cellularBars ") {
                capabilities.supportedFlags.insert(.cellularBars)
                currentFlag = .cellularBars
            } else if trimmedLine.hasPrefix("--operatorName ") {
                capabilities.supportedFlags.insert(.operatorName)
                currentFlag = .operatorName
            } else if trimmedLine.hasPrefix("--batteryState ") {
                capabilities.supportedFlags.insert(.batteryState)
                currentFlag = .batteryState
            } else if trimmedLine.hasPrefix("--batteryLevel ") {
                capabilities.supportedFlags.insert(.batteryLevel)
                currentFlag = .batteryLevel
            } else if trimmedLine.contains("must be one of"), let currentFlag {
                let values = extractQuotedValues(from: trimmedLine)
                switch currentFlag {
                case .dataNetwork:
                    capabilities.supportedDataNetworks = values
                case .wifiMode:
                    capabilities.supportedWiFiModes = values
                case .cellularMode:
                    capabilities.supportedCellularModes = values
                case .batteryState:
                    capabilities.supportedBatteryStates = values
                default:
                    break
                }
            } else if trimmedLine.contains("must be"), let currentFlag, let range = extractRange(from: trimmedLine) {
                switch currentFlag {
                case .wifiBars:
                    capabilities.wifiBarsRange = range
                case .cellularBars:
                    capabilities.cellularBarsRange = range
                case .batteryLevel:
                    capabilities.batteryLevelRange = range
                default:
                    break
                }
            }
        }

        guard !capabilities.supportedFlags.isEmpty else {
            throw StatusBarCapabilitiesError.parsingFailed("No status_bar flags were found in the active help output.")
        }

        return capabilities
    }

    private func extractQuotedValues(from line: String) -> [String] {
        let matches = line.matches(of: /'([^']+)'/)
        return matches.map { String($0.output.1) }
    }

    private func extractRange(from line: String) -> ClosedRange<Int>? {
        guard let match = line.firstMatch(of: /(\d+)-(\d+)/),
              let lowerBound = Int(match.output.1),
              let upperBound = Int(match.output.2) else {
            return nil
        }

        return lowerBound...upperBound
    }
}

enum StatusBarCapabilitiesError: LocalizedError {
    case commandFailed(String)
    case parsingFailed(String)

    var errorDescription: String? {
        switch self {
        case let .commandFailed(message):
            return "Failed to load status bar capabilities. \(message)"
        case let .parsingFailed(message):
            return "Failed to parse status bar capabilities. \(message)"
        }
    }
}
