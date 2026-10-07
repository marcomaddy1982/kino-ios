import DesignSystem
import SwiftUI

struct RegisterView: View {
    @State private var viewModel = RegisterViewModelFactory.make()

    var body: some View {
        @Bindable var viewModel = viewModel
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                        .largeIconStyle()
                        .foregroundStyle(AppColors.primary)

                    Text("register.title", bundle: .module)
                        .titleStyle()

                    Text("register.subtitle", bundle: .module)
                        .secondaryTextStyle()
                        .bodyStyle()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 32)

                VStack(spacing: 16) {
                    TextField(String(localized: "register.field.name", bundle: .module), text: $viewModel.name)
                        .formFieldStyle()
                        .textContentType(.name)
                        .autocorrectionDisabled()

                    TextField(String(localized: "register.field.email", bundle: .module), text: $viewModel.email)
                        .formFieldStyle()
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    PasswordField(placeholder: LocalizedStringResource("register.field.password", bundle: #bundle), text: $viewModel.password)

                    PasswordField(placeholder: LocalizedStringResource("register.field.confirmPassword", bundle: #bundle), text: $viewModel.confirmPassword)

                    TextField(String(localized: "register.field.phoneNumber", bundle: .module), text: $viewModel.phoneNumber)
                        .formFieldStyle()
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }
                .padding(.horizontal, 24)

                if case .error(let message) = viewModel.registerState {
                    Text(message)
                        .captionStyle()
                        .foregroundStyle(AppColors.errorRed)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                if viewModel.registerState == .loading {
                    ProgressView()
                        .padding()
                } else if viewModel.registerState != .success {
                    VStack {
                        PrimaryActionButton(title: LocalizedStringResource("register.action", bundle: #bundle)) {
                            Task { await viewModel.register() }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()
            }
        }
        .navigationTitle(LocalizedStringResource("register.navigationTitle", bundle: #bundle))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AuthContainer()
}
