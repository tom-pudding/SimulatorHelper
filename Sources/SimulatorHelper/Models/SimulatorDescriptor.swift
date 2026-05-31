import Foundation

struct SimulatorDescriptor: Identifiable, Equatable, Sendable {
    enum ProductFamily: String, Equatable, Sendable {
        case iPhone
        case iPad
        case other

        var symbolName: String {
            switch self {
            case .iPhone:
                return "iphone"
            case .iPad:
                return "ipad"
            case .other:
                return "rectangle.portrait"
            }
        }
    }

    let udid: String
    let name: String
    let runtimeIdentifier: String
    let runtimeName: String
    let deviceTypeIdentifier: String
    let productFamily: ProductFamily
    let state: String
    let lastBootedAt: Date?

    var id: String {
        udid
    }
}
