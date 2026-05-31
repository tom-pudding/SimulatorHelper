import Foundation

struct ProcessRequest: Equatable, Sendable {
    let executableURL: URL
    var arguments: [String]

    init(executableURL: URL, arguments: [String] = []) {
        self.executableURL = executableURL
        self.arguments = arguments
    }
}

struct ProcessResult: Equatable, Sendable {
    let standardOutput: String
    let standardError: String
    let exitCode: Int32

    var isSuccess: Bool {
        exitCode == 0
    }

    var combinedOutput: String {
        let trimmedOutput = standardOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedError = standardError.trimmingCharacters(in: .whitespacesAndNewlines)
        return [trimmedOutput, trimmedError]
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }
}

enum ProcessRunnerError: LocalizedError {
    case launchFailed(String)

    var errorDescription: String? {
        switch self {
        case let .launchFailed(message):
            return message
        }
    }
}
