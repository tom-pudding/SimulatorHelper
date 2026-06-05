import SwiftUI

struct ScreenshotSectionView: View {
    let hasSelectedSimulator: Bool
    let folderURL: URL
    let isChoosingFolder: Bool
    let isOpeningFolder: Bool
    let isCapturingScreenshot: Bool
    let resultMessage: String?
    let resultIsError: Bool
    let onChooseFolder: () -> Void
    let onOpenFolder: () -> Void
    let onCapture: () -> Void

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Save Folder")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(folderURL.path)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 12) {
                    Button("Change Folder", action: onChooseFolder)
                        .buttonStyle(.bordered)
                        .disabled(isChoosingFolder || isOpeningFolder || isCapturingScreenshot)

                    Button("Open Save Folder", action: onOpenFolder)
                        .buttonStyle(.bordered)
                        .disabled(isChoosingFolder || isOpeningFolder || isCapturingScreenshot)

                    Button("Capture Screenshot", action: onCapture)
                        .buttonStyle(.borderedProminent)
                        .disabled(!hasSelectedSimulator || isChoosingFolder || isOpeningFolder || isCapturingScreenshot)
                }

                if isChoosingFolder {
                    ProgressView("Waiting for folder selection…")
                        .progressViewStyle(.linear)
                }

                if isOpeningFolder {
                    ProgressView("Opening screenshot folder…")
                        .progressViewStyle(.linear)
                }

                if isCapturingScreenshot {
                    ProgressView("Capturing screenshot…")
                        .progressViewStyle(.linear)
                }

                if !hasSelectedSimulator {
                    Label("Select a booted simulator to capture screenshots. Save-folder actions remain available.", systemImage: "info.circle")
                        .foregroundStyle(.secondary)
                }

                if let resultMessage {
                    Label {
                        Text(resultMessage)
                            .fixedSize(horizontal: false, vertical: true)
                    } icon: {
                        Image(systemName: resultIsError ? "xmark.octagon" : "checkmark.seal")
                    }
                    .foregroundStyle(resultIsError ? .red : .green)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Label("Screenshot", systemImage: "camera")
        }
    }
}
