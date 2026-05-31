import Foundation

struct ScreenshotService: Sendable {
    private let processRunner: any ProcessRunning
    private let now: @Sendable () -> Date

    init(
        processRunner: any ProcessRunning = SystemProcessRunner(),
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.processRunner = processRunner
        self.now = now
    }

    func capture(from simulator: SimulatorDescriptor, destinationFolder: URL) async throws -> URL {
        let outputURL = makeOutputURL(for: simulator, destinationFolder: destinationFolder, timestamp: now())

        do {
            try FileManager.default.createDirectory(
                at: destinationFolder,
                withIntermediateDirectories: true
            )
        } catch {
            throw ScreenshotServiceError.directoryCreationFailed(error.localizedDescription)
        }

        let result = try await processRunner.run(
            ProcessRequest(
                executableURL: URL(fileURLWithPath: "/usr/bin/xcrun"),
                arguments: [
                    "simctl",
                    "io",
                    simulator.udid,
                    "screenshot",
                    outputURL.path,
                ]
            )
        )

        guard result.isSuccess else {
            throw ScreenshotServiceError.commandFailed(result.combinedOutput)
        }

        return outputURL
    }

    func makeOutputURL(for simulator: SimulatorDescriptor, destinationFolder: URL, timestamp: Date) -> URL {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"

        let sanitizedDeviceName = sanitizeFilenameComponent(simulator.name)
        let filename = "\(sanitizedDeviceName)_\(formatter.string(from: timestamp)).png"
        return destinationFolder.appendingPathComponent(filename, isDirectory: false)
    }

    private func sanitizeFilenameComponent(_ value: String) -> String {
        value
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
    }
}

enum ScreenshotServiceError: LocalizedError {
    case directoryCreationFailed(String)
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case let .directoryCreationFailed(message):
            return "Failed to prepare the screenshot folder. \(message)"
        case let .commandFailed(message):
            return "Failed to capture the simulator screenshot. \(message)"
        }
    }
}
