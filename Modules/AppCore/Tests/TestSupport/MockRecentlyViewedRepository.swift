//
//  MockRecentlyViewedRepository.swift
//  KinoTests
//
//  Created by Marco Maddalena on 27.03.26.
//

import AppFeatures
import Foundation
import Models

public final class MockRecentlyViewedRepository: RecentlyViewedRepositoryProtocol {
    public var getRecentlyViewedCallCount: Int = 0
    public var saveMovieCallCount: Int = 0
    public var clearAllCallCount: Int = 0
    
    public var mockRecentlyViewed: [Movie] = []
    public var shouldThrowOnGet: Bool = false
    public var shouldThrowOnSave: Bool = false
    public var shouldThrowOnClear: Bool = false
    
    public var lastSavedMovie: Movie?

    public init() {}

    public func getRecentlyViewed() async throws -> [Movie] {
        getRecentlyViewedCallCount += 1
        
        if shouldThrowOnGet {
            throw NSError(domain: "MockError", code: 1)
        }
        
        return mockRecentlyViewed
    }
    
    public func saveMovie(_ movie: Movie) async throws {
        saveMovieCallCount += 1
        lastSavedMovie = movie
        
        if shouldThrowOnSave {
            throw NSError(domain: "MockError", code: 1)
        }
        
        mockRecentlyViewed.insert(movie, at: 0)
    }
    
    public func clearAll() async throws {
        clearAllCallCount += 1
        
        if shouldThrowOnClear {
            throw NSError(domain: "MockError", code: 1)
        }
        
        mockRecentlyViewed = []
    }
    
    public func setMockRecentlyViewed(_ movies: [Movie]) {
        mockRecentlyViewed = movies
    }
}
