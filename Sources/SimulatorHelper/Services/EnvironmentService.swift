import Foundation

struct EnvironmentService: Sendable {
    private struct CommandFailure: Error {
        let message: String
    }

    private let processRunner: any ProcessRunning

    init(processRunner: any ProcessRunning = SystemProcessRunner()) {
        self.processRunner = processRunner
    }

    func loadStatus() async -> EnvironmentStatus {
        var status = EnvironmentStatus.empty

        await loadXcodeVersion(into: &status)
        await loadDeveloperDirectory(into: &status)
        await loadSimctlPath(into: &status)
        await loadStatusBarSupport(into: &status)

        return status
    }

    private func loadXcodeVersion(into status: inout EnvironmentStatus) async {
        switch await run("/usr/bin/xcodebuild", arguments: ["-version"]) {
        case let .success(result):
            let lines = result.standardOutput
                .split(whereSeparator: { $0.isNewline })
                .map(String.init)

            status.xcodeVersion = lines.first?
                .replacingOccurrences(of: "Xcode ", with: "")
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            status.xcodeBuild = lines
                .first(where: { $0.hasPrefix("Build version ") })?
                .replacingOccurrences(of: "Build version ", with: "")
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

            if status.xcodeVersion == nil || status.xcodeBuild == nil {
                status.warnings.append("The active Xcode version could not be parsed cleanly.")
            }
        case let .failure(failure):
            status.errors.append("Unable to determine the active Xcode version. \(failure.message)")
        }
    }

    private func loadDeveloperDirectory(into status: inout EnvironmentStatus) async {
        switch await run("/usr/bin/xcode-select", arguments: ["-p"]) {
        case let .success(result):
            let path = result.standardOutput.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if path.isEmpty {
                status.warnings.append("The active developer directory was empty.")
            } else {
                status.developerDirectory = path
            }
        case let .failure(failure):
            status.warnings.append("Unable to resolve the active developer directory. \(failure.message)")
        }
    }

    private func loadSimctlPath(into status: inout EnvironmentStatus) async {
        switch await run("/usr/bin/xcrun", arguments: ["--find", "simctl"]) {
        case let .success(result):
            let path = result.standardOutput.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if path.isEmpty {
                status.errors.append("xcrun did not return a simctl path.")
            } else {
                status.simctlPath = path
            }
        case let .failure(failure):
            status.errors.append("Unable to locate simctl via xcrun. \(failure.message)")
        }
    }

    private func loadStatusBarSupport(into status: inout EnvironmentStatus) async {
        switch await run("/usr/bin/xcrun", arguments: ["simctl", "help", "status_bar"]) {
        case let .success(result):
            let output = result.combinedOutput
            if output.contains("Usage: simctl status_bar") {
                status.statusBarSupportAvailable = true
            } else {
                status.errors.append("The active toolchain does not report simctl status_bar support.")
            }
        case let .failure(failure):
            status.errors.append("Unable to verify simctl status_bar support. \(failure.message)")
        }
    }

    private func run(_ executablePath: String, arguments: [String]) async -> Result<ProcessResult, CommandFailure> {
        do {
            let result = try await processRunner.run(
                ProcessRequest(
                    executableURL: URL(fileURLWithPath: executablePath),
                    arguments: arguments
                )
            )

            if result.isSuccess {
                return .success(result)
            }

            return .failure(CommandFailure(message: bestEffortMessage(for: result)))
        } catch {
            return .failure(CommandFailure(message: error.localizedDescription))
        }
    }

    private func bestEffortMessage(for result: ProcessResult) -> String {
        let message = result.combinedOutput
        if message.isEmpty {
            return "The command exited with code \(result.exitCode)."
        }

        return message
    }
}
