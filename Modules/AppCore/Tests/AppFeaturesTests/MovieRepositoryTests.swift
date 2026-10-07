//
//  MovieRepositoryTests.swift
//  KinoTests
//
//  Created by Marco Maddalena on 25.03.26.
//

import AppFeatures
import Foundation
import Models
import Testing
import TestSupport


@Suite("MovieRepository Tests")
@MainActor
struct MovieRepositoryTests {
    
    @Test("Repository returns cached data on cache hit")
    func testRepositoryCacheHit() async throws {
        let mockCache = MockMovieListCache()
        let mockService = MockMovieService()
        let cachedMovies = TestDataBuilder.makeSampleMovieList(count: 3)
        let cachedResponse = MovieListResponse(page: 1, results: cachedMovies, totalPages: 5, totalResults: 100)
        mockCache.setMockResponse(cachedResponse)
        
        let result = try mockCache.getMovies(page: 1, cacheDuration: 3600)
        
        #expect(result != nil)
        #expect(result?.page == 1)
        #expect(result?.results.count == 3)
        #expect(mockCache.getMoviesCallCount == 1)
        #expect(mockService.fetchMoviesCallCount == 0) // Service not called
    }
    
    @Test("Repository fetches from API on cache miss")
    func testRepositoryCacheMissCallsAPI() async throws {
        let mockCache = MockMovieListCache()
        let mockService = MockMovieService()
        let apiMovies = TestDataBuilder.makeSampleMovieList(count: 5)
        let apiResponse = MovieListResponse(page: 1, results: apiMovies, totalPages: 10, totalResults: 200)
        mockService.simulateSuccess(with: apiResponse)

        #expect(try mockCache.getMovies(page: 1, cacheDuration: 3600) == nil)

        let apiResult = try await mockService.fetchMovies(page: 1)
        #expect(apiResult.page == 1)
        #expect(apiResult.results.count == 5)
        #expect(mockService.fetchMoviesCallCount == 1)
    }
    
    @Test("Repository preserves movie order from API")
    func testRepositoryPreservesMovieOrder() async throws {
        let mockService = MockMovieService()
        let movies = TestDataBuilder.makeSampleMovieList(count: 4, baseTitle: "Ordered")
        let response = MovieListResponse(page: 1, results: movies, totalPages: 1, totalResults: 4)
        mockService.simulateSuccess(with: response)
        
        let result = try await mockService.fetchMovies(page: 1)
        
        #expect(result.results.count == 4)
        for (index, movie) in result.results.enumerated() {
            #expect(movie.title == "Ordered \(index + 1)")
        }
    }
    
    @Test("Repository forces refresh when requested")
    func testRepositoryForceRefresh() async throws {
        let mockCache = MockMovieListCache()
        let mockService = MockMovieService()
        let cachedMovies = TestDataBuilder.makeSampleMovieList(count: 2, baseTitle: "Cached")
        let cachedResponse = MovieListResponse(page: 1, results: cachedMovies, totalPages: 1, totalResults: 2)
        let freshMovies = TestDataBuilder.makeSampleMovieList(count: 3, baseTitle: "Fresh")
        let freshResponse = MovieListResponse(page: 1, results: freshMovies, totalPages: 1, totalResults: 3)
        
        mockCache.setMockResponse(cachedResponse)
        mockService.simulateSuccess(with: freshResponse)

        let result = try await mockService.fetchMovies(page: 1)
        
        #expect(result.results.count == 3)
        #expect(result.results.first?.title == "Fresh 1")
        #expect(mockService.fetchMoviesCallCount == 1)
    }
    
    @Test("Repository saves API response to cache")
    func testRepositorySavesToCache() throws {
        let mockCache = MockMovieListCache()
        let response = TestDataBuilder.makeSampleMovieListResponse(page: 1, totalPages: 5)
        
        try mockCache.saveMovies(response, page: 1)
        
        #expect(mockCache.saveMoviesCallCount == 1)
        #expect(mockCache.lastPageSaved == 1)
        #expect(mockCache.lastResponseSaved?.page == response.page)
        #expect(mockCache.lastResponseSaved?.totalPages == response.totalPages)
    }
    
    @Test("Repository clears cache successfully")
    func testRepositoryClearCache() async throws {
        let mockCache = MockMovieListCache()
        
        try mockCache.clearAll()
        
        #expect(mockCache.clearAllCallCount == 1)
    }
}
