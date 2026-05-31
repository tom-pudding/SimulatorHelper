import Foundation
@testable import SimulatorHelper

struct StubProcessRunner: ProcessRunning {
    enum StubError: Error {
        case missingResponse(String)
    }

    let responses: [String: Result<ProcessResult, Error>]

    func run(_ request: ProcessRequest) async throws -> ProcessResult {
        let key = Self.key(request.executableURL.path, request.arguments)

        guard let response = responses[key] else {
            throw StubError.missingResponse(key)
        }

        return try response.get()
    }

    static func key(_ executable: String, _ arguments: [String]) -> String {
        ([executable] + arguments).joined(separator: " ")
    }
}
