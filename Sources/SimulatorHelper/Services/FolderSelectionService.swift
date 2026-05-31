import AppKit
import Foundation

@MainActor
struct FolderSelectionService {
    func chooseFolder(startingAt currentFolder: URL?) -> URL? {
        let panel = NSOpenPanel()
        panel.title = "Choose Screenshot Folder"
        panel.message = "Select where Simulator Helper should save screenshots."
        panel.prompt = "Choose"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = currentFolder

        return panel.runModal() == .OK ? panel.url : nil
    }
}
