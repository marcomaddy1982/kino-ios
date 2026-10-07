//
//  MockSearchService.swift
//  KinoTests
//
//  Created by Marco Maddalena on 25.03.26.
//

import AppFeatures
import Foundation
import Models
import Networking

public final class MockSearchService: SearchServiceProtocol {
    public var shouldSucceed: Bool = true
    public var mockResponse: MovieListResponse?
    public var error: Error?
    
    public var searchMoviesCallCount: Int = 0
    public var lastQueryRequested: String?
    public var lastPageRequested: Int?
    
    public init() {}
    
    public func simulateSuccess(with response: MovieListResponse) {
        shouldSucceed = true
        mockResponse = response
        error = nil
    }
    
    public func simulateFailure(with error: Error) {
        shouldSucceed = false
        mockResponse = nil
        self.error = error
    }
    
    public func searchMovies(query: String, page: Int) async throws -> MovieListResponse {
        searchMoviesCallCount += 1
        lastQueryRequested = query
        lastPageRequested = page
        
        if !shouldSucceed, let error = error {
            throw error
        }
        
        guard let response = mockResponse else {
            throw NetworkError.noData
        }
        
        return response
    }
}
