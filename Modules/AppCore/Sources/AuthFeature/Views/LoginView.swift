import AppFeatures
import DesignSystem
import SwiftUI

struct LoginView: View {
    @State private var viewModel = LoginViewModelFactory.makeLoginViewModel()
    @Environment(AuthRouter.self) private var router

    var body: some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "film.stack")
                .largeIconStyle()
                .foregroundStyle(AppColors.primary)
                .padding(.bottom, 8)

            Text("auth.title", bundle: .module)
                .titleStyle()

            Text("auth.subtitle", bundle: .module)
                .secondaryTextStyle()
                .bodyStyle()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 16) {
                TextField(String(localized: "auth.field.email", bundle: .module), text: $viewModel.email)
                    .formFieldStyle()
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                PasswordField(placeholder: LocalizedStringResource("auth.field.password", bundle: #bundle), text: $viewModel.password)
            }
            .padding(.horizontal, 24)

            if case .error(let message) = viewModel.loginState {
                Text(message)
                    .captionStyle()
                    .foregroundStyle(AppColors.errorRed)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            if viewModel.loginState == .loading {
                ProgressView()
                    .padding()
            } else if viewModel.loginState != .success {
                VStack(spacing: 12) {
                    PrimaryActionButton(title: LocalizedStringResource("auth.login", bundle: #bundle)) {
                        Task { await viewModel.login() }
                    }

                    SecondaryActionButton(title: LocalizedStringResource("auth.createAccount", bundle: #bundle)) {
                        router.navigate(to: .register)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 48)
    }
}
