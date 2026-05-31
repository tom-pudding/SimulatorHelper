import SwiftUI

struct ContentView: View {
    @State private var viewModel = AppViewModel()

    var body: some View {
        NavigationSplitView {
            List {
                Section("Booted Simulators") {
                    Label("Phase 2 will load booted iPhone and iPad simulators here.", systemImage: "iphone.gen3")
                        .foregroundStyle(.secondary)
                    Label("Selection and refresh actions will become active in the next phase.", systemImage: "arrow.clockwise")
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button {
                        Task {
                            await viewModel.loadEnvironment()
                        }
                    } label: {
                        if viewModel.isLoadingEnvironment {
                            Label("Refreshing Environment…", systemImage: "hourglass")
                        } else {
                            Label("Refresh Environment", systemImage: "arrow.clockwise")
                        }
                    }
                    .disabled(viewModel.isLoadingEnvironment)
                }
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 250, ideal: 280)
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    EnvironmentBannerView(
                        status: viewModel.environmentStatus,
                        isLoading: viewModel.isLoadingEnvironment
                    )
                    toolchainDetails
                    nextSteps
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .task {
            await viewModel.loadEnvironmentIfNeeded()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Simulator Helper")
                .font(.system(size: 32, weight: .semibold, design: .rounded))

            Text("Phase 1 establishes the macOS app shell and verifies the active Xcode toolchain before simulator-specific work begins.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var toolchainDetails: some View {
        GroupBox {
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                detailRow(label: "Xcode Version", value: viewModel.environmentStatus.xcodeVersion ?? "Unknown")
                detailRow(label: "Build", value: viewModel.environmentStatus.xcodeBuild ?? "Unknown")
                detailRow(label: "Developer Directory", value: viewModel.environmentStatus.developerDirectory ?? "Unknown")
                detailRow(label: "simctl Path", value: viewModel.environmentStatus.simctlPath ?? "Unknown")
                detailRow(
                    label: "status_bar Support",
                    value: viewModel.environmentStatus.statusBarSupportAvailable ? "Available" : "Unavailable"
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Label("Toolchain Details", systemImage: "wrench.and.screwdriver")
        }
    }

    private var nextSteps: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Label("Phase 2 will add booted simulator discovery and selection.", systemImage: "sidebar.leading")
                Label("Phase 3 will add the MVP status bar controls and apply/clear actions.", systemImage: "switch.2")
                Label("Phase 4 will add screenshot folder selection and capture.", systemImage: "camera")
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Label("Implementation Roadmap", systemImage: "list.bullet.rectangle")
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        GridRow {
            Text(label)
                .foregroundStyle(.secondary)
            Text(value)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
