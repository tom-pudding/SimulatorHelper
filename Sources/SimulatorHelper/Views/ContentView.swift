import SwiftUI

struct ContentView: View {
    @State private var viewModel = AppViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationSplitView {
            List(selection: $viewModel.selectedSimulatorID) {
                Section("Booted Simulators") {
                    if viewModel.isLoadingSimulators {
                        Label("Loading booted simulators…", systemImage: "hourglass")
                            .foregroundStyle(.secondary)
                    } else if let simulatorErrorMessage = viewModel.simulatorErrorMessage {
                        Label(simulatorErrorMessage, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                    } else if viewModel.simulators.isEmpty {
                        Label("Boot an iPhone or iPad simulator in Simulator.app to begin.", systemImage: "power")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.simulators) { simulator in
                            simulatorRow(for: simulator)
                                .tag(Optional(simulator.id))
                        }
                    }
                }

                Section("Actions") {
                    Button {
                        Task {
                            await viewModel.loadSimulators()
                        }
                    } label: {
                        if viewModel.isLoadingSimulators {
                            Label("Refreshing Simulators…", systemImage: "hourglass")
                        } else {
                            Label("Refresh Simulators", systemImage: "arrow.clockwise")
                        }
                    }
                    .disabled(viewModel.isLoadingSimulators)

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
                    selectedSimulatorCard
                    statusBarSection
                    screenshotSection
                    toolchainDetails
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .task {
            await viewModel.loadInitialData()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Simulator Helper")
                .font(.system(size: 32, weight: .semibold, design: .rounded))
        }
    }

    private var selectedSimulatorCard: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                if let simulator = viewModel.selectedSimulator {
                    Label(simulator.name, systemImage: simulator.productFamily.symbolName)
                        .font(.headline)

                    detailLine(label: "Runtime", value: simulator.runtimeName)
                    detailLine(label: "State", value: simulator.state)
                    detailLine(label: "UDID", value: simulator.udid)
                } else if viewModel.isLoadingSimulators {
                    ProgressView("Looking for booted simulators…")
                        .progressViewStyle(.linear)
                } else {
                    ContentUnavailableView(
                        "No Booted Simulator Selected",
                        systemImage: "iphone.slash",
                        description: Text("Boot an iPhone or iPad simulator, then use Refresh Simulators to load it here.")
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Label("Selected Simulator", systemImage: "sidebar.right")
        }
    }

    private var statusBarSection: some View {
        StatusBarFormView(
            configuration: $viewModel.statusBarConfiguration,
            capabilities: viewModel.statusBarCapabilities,
            allowsDateAndTimeOverride: viewModel.allowsDateAndTimeOverride,
            hasSelectedSimulator: viewModel.selectedSimulator != nil,
            isLoadingCapabilities: viewModel.isLoadingStatusBarCapabilities,
            capabilitiesErrorMessage: viewModel.statusBarCapabilitiesErrorMessage,
            isPerformingAction: viewModel.isPerformingStatusBarAction,
            resultMessage: viewModel.statusBarResultMessage,
            resultIsError: viewModel.statusBarResultIsError,
            onReloadCapabilities: {
                Task {
                    await viewModel.loadStatusBarCapabilities()
                }
            },
            onApply: {
                Task {
                    await viewModel.applyStatusBarConfiguration()
                }
            },
            onClear: {
                Task {
                    await viewModel.clearStatusBarConfiguration()
                }
            }
        )
    }

    private var screenshotSection: some View {
        ScreenshotSectionView(
            folderURL: viewModel.screenshotFolderURL,
            isChoosingFolder: viewModel.isChoosingScreenshotFolder,
            isCapturingScreenshot: viewModel.isCapturingScreenshot,
            resultMessage: viewModel.screenshotResultMessage,
            resultIsError: viewModel.screenshotResultIsError,
            onChooseFolder: {
                Task {
                    await viewModel.chooseScreenshotFolder()
                }
            },
            onCapture: {
                Task {
                    await viewModel.captureScreenshot()
                }
            }
        )
        .disabled(viewModel.selectedSimulator == nil || viewModel.isLoadingSimulators)
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

    private func detailRow(label: String, value: String) -> some View {
        GridRow {
            Text(label)
                .foregroundStyle(.secondary)
            Text(value)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func detailLine(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .textSelection(.enabled)
        }
    }

    private func simulatorRow(for simulator: SimulatorDescriptor) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(simulator.name, systemImage: simulator.productFamily.symbolName)
                .foregroundStyle(.primary)
            Text(simulator.runtimeName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
