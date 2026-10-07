//
//  MockMovieListCache.swift
//  KinoTests
//
//  Created by Marco Maddalena on 25.03.26.
//

import Foundation
import Models
import Networking

public final class MockMovieListCache {
    public var getMoviesCallCount: Int = 0
    public var saveMoviesCallCount: Int = 0
    public var clearAllCallCount: Int = 0
    
    public var mockResponse: MovieListResponse?
    public var shouldThrowOnGet: Bool = false
    public var shouldThrowOnSave: Bool = false
    public var shouldThrowOnClear: Bool = false
    
    public var lastPageRequested: Int?
    public var lastCacheDurationRequested: TimeInterval?
    public var lastResponseSaved: MovieListResponse?
    public var lastPageSaved: Int?

    public init() {}

    public func getMovies(page: Int, cacheDuration: TimeInterval) throws -> MovieListResponse? {
        getMoviesCallCount += 1
        lastPageRequested = page
        lastCacheDurationRequested = cacheDuration
        
        if shouldThrowOnGet {
            throw NetworkError.noData
        }
        
        return mockResponse
    }
    
    public func saveMovies(_ response: MovieListResponse, page: Int) throws {
        saveMoviesCallCount += 1
        lastResponseSaved = response
        lastPageSaved = page
        
        if shouldThrowOnSave {
            throw NetworkError.noData
        }
    }
    
    public func clearAll() throws {
        clearAllCallCount += 1
        
        if shouldThrowOnClear {
            throw NetworkError.noData
        }
    }
    
    // Helper to set mock response
    public func setMockResponse(_ response: MovieListResponse) {
        mockResponse = response
    }
}
