import SwiftUI

public struct PasswordField: View {
    let placeholder: LocalizedStringResource
    @Binding var text: String
    @State private var isVisible: Bool = false

    public init(placeholder: LocalizedStringResource, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        HStack {
            Group {
                if isVisible {
                    TextField(String(localized: placeholder), text: $text)
                        .textContentType(.password)
                } else {
                    SecureField(String(localized: placeholder), text: $text)
                        .textContentType(.password)
                }
            }
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)

            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .formFieldStyle()
    }
}

#Preview {
    PasswordField(placeholder: "Password", text: .constant(""))
        .padding()
}
