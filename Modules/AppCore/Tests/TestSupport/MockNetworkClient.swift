//
//  MockNetworkClient.swift
//  KinoTests
//
//  Created by Marco Maddalena on 22.03.26.
//

import Foundation
import Networking

public final class MockNetworkClient: NetworkClientProtocol, Sendable {
    public nonisolated(unsafe) var shouldSucceed: Bool = true
    public nonisolated(unsafe) var mockResponse: Data?
    public nonisolated(unsafe) var error: NetworkError?
    
    public init() {}

    public func simulateSuccess(with data: Data) {
        shouldSucceed = true
        mockResponse = data
        error = nil
    }

    public func simulateFailure(with error: NetworkError) {
        shouldSucceed = false
        mockResponse = nil
        self.error = error
    }
    
    public func fetch<R: NetworkRequest>(_ request: R) async throws -> R.Response {
        if !shouldSucceed, let error = error {
            throw error
        }
        
        guard let data = mockResponse else {
            throw NetworkError.noData
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(R.Response.self, from: data)
    }
}
