import Foundation

struct SystemProcessRunner: ProcessRunning {
    func run(_ request: ProcessRequest) async throws -> ProcessResult {
        try await Task.detached(priority: .userInitiated) {
            let process = Process()
            let outputPipe = Pipe()
            let errorPipe = Pipe()

            process.executableURL = request.executableURL
            process.arguments = request.arguments
            process.standardOutput = outputPipe
            process.standardError = errorPipe

            do {
                try process.run()
            } catch {
                throw ProcessRunnerError.launchFailed(
                    "Failed to launch \(request.executableURL.path): \(error.localizedDescription)"
                )
            }

            process.waitUntilExit()

            let standardOutput = String(
                decoding: outputPipe.fileHandleForReading.readDataToEndOfFile(),
                as: UTF8.self
            )
            let standardError = String(
                decoding: errorPipe.fileHandleForReading.readDataToEndOfFile(),
                as: UTF8.self
            )

            return ProcessResult(
                standardOutput: standardOutput,
                standardError: standardError,
                exitCode: process.terminationStatus
            )
        }.value
    }
}
