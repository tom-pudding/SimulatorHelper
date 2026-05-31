import Foundation
import Testing
@testable import SimulatorHelper

struct SimulatorInventoryServiceTests {
    @Test
    func returnsOnlyBootedIPhoneAndIPadSimulators() async throws {
        let runner = StubProcessRunner(
            responses: [
                StubProcessRunner.key("/usr/bin/xcrun", ["simctl", "list", "devices", "--json"]): .success(
                    ProcessResult(
                        standardOutput: sampleDeviceJSON,
                        standardError: "",
                        exitCode: 0
                    )
                ),
            ]
        )

        let simulators = try await SimulatorInventoryService(processRunner: runner).loadBootedSimulators()

        #expect(simulators.count == 2)
        #expect(simulators.map { $0.name } == ["iPad Pro 13-inch (M5)", "iPhone 17 Pro"])
        #expect(simulators.map { $0.productFamily } == [SimulatorDescriptor.ProductFamily.iPad, .iPhone])
        #expect(simulators.allSatisfy { $0.state == "Booted" })
    }

    @Test
    func throwsWhenJSONCannotBeDecoded() async {
        let runner = StubProcessRunner(
            responses: [
                StubProcessRunner.key("/usr/bin/xcrun", ["simctl", "list", "devices", "--json"]): .success(
                    ProcessResult(
                        standardOutput: "{not valid json}",
                        standardError: "",
                        exitCode: 0
                    )
                ),
            ]
        )

        await #expect(throws: SimulatorInventoryError.self) {
            try await SimulatorInventoryService(processRunner: runner).loadBootedSimulators()
        }
    }

    @Test
    func throwsWhenSimctlCommandFails() async {
        let runner = StubProcessRunner(
            responses: [
                StubProcessRunner.key("/usr/bin/xcrun", ["simctl", "list", "devices", "--json"]): .success(
                    ProcessResult(
                        standardOutput: "",
                        standardError: "simctl failed",
                        exitCode: 1
                    )
                ),
            ]
        )

        await #expect(throws: SimulatorInventoryError.self) {
            try await SimulatorInventoryService(processRunner: runner).loadBootedSimulators()
        }
    }
}

private let sampleDeviceJSON = """
{
  "devices" : {
    "com.apple.CoreSimulator.SimRuntime.iOS-26-3" : [
      {
        "lastBootedAt" : "2026-05-31T12:39:20Z",
        "udid" : "38C2AD9E-9318-445C-95CC-AAC69492FC2D",
        "isAvailable" : true,
        "deviceTypeIdentifier" : "com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro",
        "state" : "Booted",
        "name" : "iPhone 17 Pro"
      },
      {
        "udid" : "DFF39A57-EB80-4F2B-A59D-E23CCCCDE33E",
        "isAvailable" : true,
        "deviceTypeIdentifier" : "com.apple.CoreSimulator.SimDeviceType.iPhone-17",
        "state" : "Shutdown",
        "name" : "iPhone 17"
      },
      {
        "lastBootedAt" : "2026-05-31T13:40:00Z",
        "udid" : "3FE64A14-8849-430C-87A4-1304F9E9F791",
        "isAvailable" : true,
        "deviceTypeIdentifier" : "com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M5-12GB",
        "state" : "Booted",
        "name" : "iPad Pro 13-inch (M5)"
      }
    ],
    "com.apple.CoreSimulator.SimRuntime.tvOS-26-2" : [
      {
        "udid" : "TV-DEVICE-1",
        "isAvailable" : true,
        "deviceTypeIdentifier" : "com.apple.CoreSimulator.SimDeviceType.Apple-TV-4K-3rd-generation-4K",
        "state" : "Booted",
        "name" : "Apple TV 4K"
      }
    ]
  }
}
"""
