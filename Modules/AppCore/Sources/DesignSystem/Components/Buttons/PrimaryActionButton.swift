import SwiftUI

public struct PrimaryActionButton: View {
    let title: LocalizedStringResource
    let action: () -> Void

    public init(title: LocalizedStringResource, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppColors.primary)
                .cornerRadius(8)
        }
    }
}

#Preview {
    PrimaryActionButton(title: "Try Again") {
        print("Button tapped")
    }
}
