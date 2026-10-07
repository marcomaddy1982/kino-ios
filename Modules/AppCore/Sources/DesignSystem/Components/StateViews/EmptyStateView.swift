import SwiftUI

public struct EmptyStateView: View {
    let icon: String
    let title: LocalizedStringResource
    let message: LocalizedStringResource

    public init(icon: String, title: LocalizedStringResource, message: LocalizedStringResource) {
        self.icon = icon
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .largeIconStyle()
                .foregroundColor(.gray)

            Text(title)
                .titleStyle()

            Text(message)
                .font(AppFonts.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        icon: "folder.fill",
        title: "No Results",
        message: "Try searching for something else"
    )
}
