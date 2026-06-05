import Foundation
import Testing
@testable import SimulatorHelper

@MainActor
struct FolderOpeningServiceTests {
    @Test
    func createsFolderBeforeOpeningIt() throws {
        let folderURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        var openedURL: URL?
        let service = FolderOpeningService(openHandler: { url in
            openedURL = url
            return true
        })

        try service.openFolder(at: folderURL)

        #expect(FileManager.default.fileExists(atPath: folderURL.path))
        #expect(openedURL == folderURL)
    }

    @Test
    func throwsWhenOpenHandlerFails() throws {
        let folderURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let service = FolderOpeningService(openHandler: { _ in false })

        #expect(throws: FolderOpeningError.self) {
            try service.openFolder(at: folderURL)
        }
    }

    @Test
    func throwsWhenFolderCannotBePrepared() throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: false)
        FileManager.default.createFile(atPath: fileURL.path, contents: Data())
        let service = FolderOpeningService(openHandler: { _ in true })

        #expect(throws: FolderOpeningError.self) {
            try service.openFolder(at: fileURL.appendingPathComponent("Nested", isDirectory: true))
        }
    }
}
