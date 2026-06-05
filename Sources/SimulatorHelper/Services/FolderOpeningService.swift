import AppKit
import Foundation

@MainActor
struct FolderOpeningService {
    private let fileManager: FileManager
    private let openHandler: @MainActor (URL) -> Bool

    init(
        fileManager: FileManager = .default,
        openHandler: @escaping @MainActor (URL) -> Bool = { NSWorkspace.shared.open($0) }
    ) {
        self.fileManager = fileManager
        self.openHandler = openHandler
    }

    func openFolder(at url: URL) throws {
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            throw FolderOpeningError.directoryPreparationFailed(error.localizedDescription)
        }

        guard openHandler(url) else {
            throw FolderOpeningError.openFailed(url.path)
        }
    }
}

enum FolderOpeningError: LocalizedError {
    case directoryPreparationFailed(String)
    case openFailed(String)

    var errorDescription: String? {
        switch self {
        case let .directoryPreparationFailed(message):
            return "Failed to prepare the screenshot folder for opening. \(message)"
        case let .openFailed(path):
            return "Failed to open the screenshot folder at \(path)."
        }
    }
}
