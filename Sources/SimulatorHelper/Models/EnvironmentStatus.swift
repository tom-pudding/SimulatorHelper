import Foundation

struct EnvironmentStatus: Equatable, Sendable {
    enum State: Sendable {
        case ready
        case warning
        case error
    }

    var xcodeVersion: String?
    var xcodeBuild: String?
    var developerDirectory: String?
    var simctlPath: String?
    var statusBarSupportAvailable: Bool
    var warnings: [String]
    var errors: [String]

    static let empty = EnvironmentStatus(
        xcodeVersion: nil,
        xcodeBuild: nil,
        developerDirectory: nil,
        simctlPath: nil,
        statusBarSupportAvailable: false,
        warnings: [],
        errors: []
    )

    var isReady: Bool {
        errors.isEmpty
    }

    var state: State {
        if !errors.isEmpty {
            return .error
        }

        if !warnings.isEmpty {
            return .warning
        }

        return .ready
    }

    var title: String {
        switch state {
        case .ready:
            return "Environment Ready"
        case .warning:
            return "Environment Ready With Warnings"
        case .error:
            return "Environment Configuration Needed"
        }
    }

    var summary: String {
        if let error = errors.first {
            return error
        }

        if let warning = warnings.first {
            return warning
        }

        return "xcrun simctl status_bar is available in the active Xcode toolchain."
    }
}
