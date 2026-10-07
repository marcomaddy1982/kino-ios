//
//  MockMovieRepository.swift
//  KinoTests
//
//  Created by Marco Maddalena on 25.03.26.
//

import AppFeatures
import Foundation
import Models
import Networking

public final class MockMovieRepository: MovieRepositoryProtocol {
    public var getMoviesCallCount: Int = 0
    public var clearCacheCallCount: Int = 0
    
    public var mockResponse: MovieListResponse?
    public var shouldThrowOnGet: Bool = false
    public var shouldThrowOnClear: Bool = false
    
    public var lastPageRequested: Int?
    public var lastForceRefreshRequested: Bool?

    public init() {}

    public func getMovies(page: Int, forceRefresh: Bool = false) async throws -> MovieListResponse {
        getMoviesCallCount += 1
        lastPageRequested = page
        lastForceRefreshRequested = forceRefresh
        
        if shouldThrowOnGet {
            throw NetworkError.noData
        }
        
        guard let response = mockResponse else {
            throw NetworkError.noData
        }
        
        return response
    }
    
    public func clearCache() async throws {
        clearCacheCallCount += 1
        
        if shouldThrowOnClear {
            throw NetworkError.noData
        }
    }
    
    // Helper to set mock response
    public func setMockResponse(_ response: MovieListResponse) {
        mockResponse = response
    }
}
