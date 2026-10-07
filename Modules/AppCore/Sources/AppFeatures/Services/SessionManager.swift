import Foundation
import Observation

private let accessTokenKey = "com.kino.accessToken"
private let refreshTokenKey = "com.kino.refreshToken"

public protocol SessionManagerProtocol {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    func save(accessToken: String, refreshToken: String) throws
    func deleteSession() throws
}

@Observable
public final class SessionManager: SessionManagerProtocol {
    @ObservationIgnored @Injected<KeychainServiceProtocol> private var keychainService: any KeychainServiceProtocol

    public private(set) var accessToken: String?
    public private(set) var refreshToken: String?

    public init() {
        accessToken = try? keychainService.load(for: accessTokenKey)
        refreshToken = try? keychainService.load(for: refreshTokenKey)
    }

    public func save(accessToken: String, refreshToken: String) throws {
        try keychainService.save(accessToken, for: accessTokenKey)
        try keychainService.save(refreshToken, for: refreshTokenKey)
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    public func deleteSession() throws {
        try keychainService.delete(for: accessTokenKey)
        try keychainService.delete(for: refreshTokenKey)
        self.accessToken = nil
        self.refreshToken = nil
    }
}
