import SwiftUI

public struct SecondaryActionButton: View {
    let title: LocalizedStringResource
    let action: () -> Void

    public init(title: LocalizedStringResource, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundStyle(AppColors.primary)
                .padding()
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.primary, lineWidth: 1.5)
                )
        }
    }
}

#Preview {
    SecondaryActionButton(title: "Create an account") {
        print("Button tapped")
    }
    .padding()
}
