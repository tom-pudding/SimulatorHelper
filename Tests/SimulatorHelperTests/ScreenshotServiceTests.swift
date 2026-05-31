import Foundation
import Testing
@testable import SimulatorHelper

struct ScreenshotServiceTests {
    @Test
    func buildsExpectedFilename() {
        let timestamp = ISO8601DateFormatter().date(from: "2026-05-31T12:40:00Z")!
        let service = ScreenshotService(now: { timestamp })
        let folder = URL(fileURLWithPath: "/tmp/Simulator Helper", isDirectory: true)

        let outputURL = service.makeOutputURL(for: sampleSimulator, destinationFolder: folder, timestamp: timestamp)

        #expect(outputURL.lastPathComponent == expectedFilename(for: timestamp))
    }

    @Test
    func captureBuildsExpectedCommand() async throws {
        let timestamp = ISO8601DateFormatter().date(from: "2026-05-31T12:40:00Z")!
        let runner = RecordingProcessRunner(
            result: ProcessResult(
                standardOutput: "Wrote screenshot to: /tmp/Simulator Helper/iPhone 17 Pro_2026-05-31_12-40-00.png",
                standardError: "",
                exitCode: 0
            )
        )
        let service = ScreenshotService(
            processRunner: runner,
            now: { timestamp }
        )
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        let outputURL = try await service.capture(from: sampleSimulator, destinationFolder: folder)
        let requests = await runner.requests

        #expect(FileManager.default.fileExists(atPath: folder.path))
        #expect(outputURL.lastPathComponent == expectedFilename(for: timestamp))
        #expect(requests.count == 1)
        #expect(requests[0].arguments == [
            "simctl",
            "io",
            sampleSimulator.udid,
            "screenshot",
            outputURL.path,
        ])
    }
}

private func expectedFilename(for timestamp: Date) -> String {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
    return "iPhone 17 Pro_\(formatter.string(from: timestamp)).png"
}

actor RecordingProcessRunner: ProcessRunning {
    private(set) var requests: [ProcessRequest] = []
    let result: ProcessResult

    init(result: ProcessResult) {
        self.result = result
    }

    func run(_ request: ProcessRequest) async throws -> ProcessResult {
        requests.append(request)
        return result
    }
}

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
