import Testing
import TestSupport
import Foundation
@testable import AuthFeature

@Suite("RegisterViewModel Tests")
@MainActor
struct RegisterViewModelTests {

    private func makeSUT() -> (RegisterViewModel, MockAuthService, MockSessionManager) {
        let authService = MockAuthService()
        let sessionManager = MockSessionManager()
        let viewModel = RegisterViewModel(authService: authService, sessionManager: sessionManager)
        return (viewModel, authService, sessionManager)
    }

    private func fillValidForm(_ sut: RegisterViewModel) {
        sut.name = "Test User"
        sut.email = "test@example.com"
        sut.password = "Password1"
        sut.confirmPassword = "Password1"
        sut.phoneNumber = "+391234567890"
    }

    @Test("register success saves tokens to session")
    func test_register_success_savesTokensToSession() async {
        let (sut, _, sessionManager) = makeSUT()
        fillValidForm(sut)

        await sut.register()

        #expect(sessionManager.lastSavedAccessToken == "mock_access_token")
        #expect(sessionManager.lastSavedRefreshToken == "mock_refresh_token")
    }

    @Test("register failure sets error state")
    func test_register_failure_setsErrorState() async {
        let (sut, authService, _) = makeSUT()
        fillValidForm(sut)
        authService.shouldThrow = true

        await sut.register()

        if case .error = sut.registerState { } else {
            Issue.record("Expected error state")
        }
    }

    @Test("validation fails when passwords do not match")
    func test_validate_passwordMismatch_setsError() async {
        let (sut, _, _) = makeSUT()
        fillValidForm(sut)
        sut.confirmPassword = "Different1"

        await sut.register()

        #expect(sut.registerState == .error(String(localized: "register.error.passwordMismatch", bundle: .module)))
    }

    @Test("validation fails when password is too short")
    func test_validate_passwordTooShort_setsError() async {
        let (sut, _, _) = makeSUT()
        fillValidForm(sut)
        sut.password = "Pass1"
        sut.confirmPassword = "Pass1"

        await sut.register()

        #expect(sut.registerState == .error(String(localized: "register.error.passwordTooShort", bundle: .module)))
    }

    @Test("validation fails when password has no uppercase letter")
    func test_validate_passwordNoUppercase_setsError() async {
        let (sut, _, _) = makeSUT()
        fillValidForm(sut)
        sut.password = "password1"
        sut.confirmPassword = "password1"

        await sut.register()

        #expect(sut.registerState == .error(String(localized: "register.error.passwordNoUppercase", bundle: .module)))
    }

    @Test("validation fails when password has no number")
    func test_validate_passwordNoNumber_setsError() async {
        let (sut, _, _) = makeSUT()
        fillValidForm(sut)
        sut.password = "Password"
        sut.confirmPassword = "Password"

        await sut.register()

        #expect(sut.registerState == .error(String(localized: "register.error.passwordNoNumber", bundle: .module)))
    }
}
