import SwiftUI

public struct ErrorStateView<Content: View>: View {
    let errorMessage: String
    let onRetry: () async -> Void
    let retryButtonTitle: LocalizedStringResource?
    @ViewBuilder let additionalContent: () -> Content

    public init(
        errorMessage: String,
        retryButtonTitle: LocalizedStringResource? = nil,
        onRetry: @escaping () async -> Void,
        @ViewBuilder additionalContent: @escaping () -> Content = { EmptyView() }
    ) {
        self.errorMessage = errorMessage
        self.retryButtonTitle = retryButtonTitle
        self.onRetry = onRetry
        self.additionalContent = additionalContent
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .largeIconStyle()
                .foregroundColor(AppColors.errorRed)
            
            Text("common.error.title", bundle: .module)
                .titleStyle()
            
            Text(errorMessage)
                .font(AppFonts.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            PrimaryActionButton(title: retryButtonTitle ?? LocalizedStringResource("common.error.retry", bundle: #bundle)) {
                Task {
                    await onRetry()
                }
            }
            
            additionalContent()
        }
    }
}

#Preview {
    ErrorStateView(
        errorMessage: "Failed to load data",
        onRetry: {
            print("Retry tapped")
        }
    )
}
