import SwiftUI

struct EnvironmentBannerView: View {
    let status: EnvironmentStatus
    let isLoading: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: iconName)
                .font(.title2.weight(.semibold))
                .foregroundStyle(accentColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Text(statusText)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(accentColor)
                }

                if isLoading {
                    ProgressView("Checking the active Xcode toolchain…")
                        .progressViewStyle(.linear)
                } else {
                    Text(status.summary)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(accentColor.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(accentColor.opacity(0.25), lineWidth: 1)
        )
    }

    private var title: String {
        isLoading ? "Checking Environment" : status.title
    }

    private var statusText: String {
        if isLoading {
            return "Loading"
        }

        switch status.state {
        case .ready:
            return "Ready"
        case .warning:
            return "Warning"
        case .error:
            return "Needs Attention"
        }
    }

    private var iconName: String {
        if isLoading {
            return "hourglass"
        }

        switch status.state {
        case .ready:
            return "checkmark.shield"
        case .warning:
            return "exclamationmark.triangle"
        case .error:
            return "xmark.octagon"
        }
    }

    private var accentColor: Color {
        if isLoading {
            return .blue
        }

        switch status.state {
        case .ready:
            return .green
        case .warning:
            return .orange
        case .error:
            return .red
        }
    }
}
