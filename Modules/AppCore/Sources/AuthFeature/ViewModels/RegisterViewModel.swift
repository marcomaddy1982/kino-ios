import AppFeatures
import Foundation
import Models
import Observation

enum RegisterState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}

@Observable
final class RegisterViewModel {
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var name: String = ""
    var phoneNumber: String = ""
    var registerState: RegisterState = .idle

    private let authService: any AuthServiceProtocol
    private let sessionManager: any SessionManagerProtocol

    init(authService: any AuthServiceProtocol, sessionManager: any SessionManagerProtocol) {
        self.authService = authService
        self.sessionManager = sessionManager
    }

    func register() async {
        guard let validationError = validate() else {
            await performRegister()
            return
        }
        registerState = .error(validationError)
    }

    private func validate() -> String? {
        if password != confirmPassword {
            return String(localized: "register.error.passwordMismatch", bundle: .module)
        }
        if password.count < 8 {
            return String(localized: "register.error.passwordTooShort", bundle: .module)
        }
        if !password.contains(where: { $0.isUppercase }) {
            return String(localized: "register.error.passwordNoUppercase", bundle: .module)
        }
        if !password.contains(where: { $0.isNumber }) {
            return String(localized: "register.error.passwordNoNumber", bundle: .module)
        }
        return nil
    }

    private func performRegister() async {
        registerState = .loading
        do {
            let response = try await authService.register(
                email: email,
                password: password,
                name: name,
                phoneNumber: phoneNumber
            )
            try sessionManager.save(accessToken: response.accessToken, refreshToken: response.refreshToken)
            registerState = .success
        } catch {
            registerState = .error(error.localizedDescription)
        }
    }
}
