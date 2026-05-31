import Foundation

struct SimulatorInventoryService: Sendable {
    private let processRunner: any ProcessRunning

    init(processRunner: any ProcessRunning = SystemProcessRunner()) {
        self.processRunner = processRunner
    }

    func loadBootedSimulators() async throws -> [SimulatorDescriptor] {
        let result = try await processRunner.run(
            ProcessRequest(
                executableURL: URL(fileURLWithPath: "/usr/bin/xcrun"),
                arguments: ["simctl", "list", "devices", "--json"]
            )
        )

        guard result.isSuccess else {
            throw SimulatorInventoryError.commandFailed(result.combinedOutput)
        }

        let response: SimctlDeviceListResponse

        do {
            response = try JSONDecoder().decode(SimctlDeviceListResponse.self, from: Data(result.standardOutput.utf8))
        } catch {
            throw SimulatorInventoryError.decodingFailed(error.localizedDescription)
        }

        let supportedRuntimePrefixes = [
            "com.apple.CoreSimulator.SimRuntime.iOS-",
            "com.apple.CoreSimulator.SimRuntime.iPadOS-",
        ]

        let simulators = response.devices
            .filter { runtimeIdentifier, _ in
                supportedRuntimePrefixes.contains { runtimeIdentifier.hasPrefix($0) }
            }
            .flatMap { runtimeIdentifier, devices in
                devices.compactMap { device in
                    guard device.state == "Booted", device.isAvailable != false else {
                        return nil
                    }

                    let productFamily = productFamily(
                        for: device.deviceTypeIdentifier,
                        name: device.name
                    )
                    guard productFamily == .iPhone || productFamily == .iPad else {
                        return nil
                    }

                    return SimulatorDescriptor(
                        udid: device.udid,
                        name: device.name,
                        runtimeIdentifier: runtimeIdentifier,
                        runtimeName: runtimeName(from: runtimeIdentifier),
                        deviceTypeIdentifier: device.deviceTypeIdentifier,
                        productFamily: productFamily,
                        state: device.state,
                        lastBootedAt: parseDate(device.lastBootedAt)
                    )
                }
            }
            .sorted(by: sortOrder)

        return simulators
    }

    private func sortOrder(lhs: SimulatorDescriptor, rhs: SimulatorDescriptor) -> Bool {
        switch (lhs.lastBootedAt, rhs.lastBootedAt) {
        case let (left?, right?) where left != right:
            return left > right
        case (.some, .none):
            return true
        case (.none, .some):
            return false
        default:
            if lhs.productFamily != rhs.productFamily {
                return lhs.productFamily.rawValue < rhs.productFamily.rawValue
            }

            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    private func productFamily(for deviceTypeIdentifier: String, name: String) -> SimulatorDescriptor.ProductFamily {
        if deviceTypeIdentifier.contains("iPad") || name.hasPrefix("iPad") {
            return .iPad
        }

        if deviceTypeIdentifier.contains("iPhone") || name.hasPrefix("iPhone") {
            return .iPhone
        }

        return .other
    }

    private func runtimeName(from identifier: String) -> String {
        let prefix = "com.apple.CoreSimulator.SimRuntime."
        let runtime = identifier.replacingOccurrences(of: prefix, with: "")
        let components = runtime.split(separator: "-")

        guard let platform = components.first, components.count > 1 else {
            return runtime
        }

        let version = components.dropFirst().joined(separator: ".")
        return "\(platform) \(version)"
    }

    private func parseDate(_ value: String?) -> Date? {
        guard let value else {
            return nil
        }

        let formatter = ISO8601DateFormatter()
        return formatter.date(from: value)
    }
}

private struct SimctlDeviceListResponse: Decodable {
    let devices: [String: [SimctlDevice]]
}

private struct SimctlDevice: Decodable {
    let udid: String
    let name: String
    let state: String
    let isAvailable: Bool?
    let deviceTypeIdentifier: String
    let lastBootedAt: String?
}

enum SimulatorInventoryError: LocalizedError {
    case commandFailed(String)
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case let .commandFailed(message):
            return "Failed to load booted simulators. \(message)"
        case let .decodingFailed(message):
            return "Failed to decode the simulator list. \(message)"
        }
    }
}
