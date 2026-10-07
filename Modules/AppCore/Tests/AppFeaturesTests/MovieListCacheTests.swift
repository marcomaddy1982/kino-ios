//
//  MovieListCacheTests.swift
//  KinoTests
//
//  Created by Marco Maddalena on 25.03.26.
//

import AppFeatures
import Foundation
import Models
import SwiftData
import Testing
import TestSupport


@Suite("MovieListCache Tests")
@MainActor
struct MovieListCacheTests {
    
    @Test("Cache returns nil when no data exists")
    func testCacheReturnNilWhenEmpty() throws {
        let context = try TestModelContainer.createContext()
        let cache = MovieListCache(modelContext: context)
        
        let result = try cache.getMovies(page: 1, cacheDuration: 3600)
        
        #expect(result == nil)
    }
    
    @Test("Cache saves and retrieves movies successfully")
    func testCacheSaveAndRetrieve() throws {
        let context = try TestModelContainer.createContext()
        let cache = MovieListCache(modelContext: context)
        let movies = TestDataBuilder.makeSampleMovieList(count: 3)
        let response = MovieListResponse(page: 1, results: movies, totalPages: 10, totalResults: 200)
        
        try cache.saveMovies(response, page: 1)
        let result = try cache.getMovies(page: 1, cacheDuration: 3600)
        
        #expect(result != nil)
        #expect(result?.page == 1)
        #expect(result?.results.count == 3)
        #expect(result?.totalPages == 10)
    }
    
    @Test("Cache preserves movie order from API response")
    func testCachePreservesMovieOrder() throws {
        let context = try TestModelContainer.createContext()
        let cache = MovieListCache(modelContext: context)
        let movies = TestDataBuilder.makeSampleMovieList(count: 5, baseTitle: "Movie")
        let response = MovieListResponse(page: 1, results: movies, totalPages: 1, totalResults: 5)
        
        try cache.saveMovies(response, page: 1)
        let result = try cache.getMovies(page: 1, cacheDuration: 3600)
        
        #expect(result?.results.count == 5)
        for (index, movie) in result?.results.enumerated() ?? [].enumerated() {
            #expect(movie.title == "Movie \(index + 1)")
        }
    }
    
    @Test("Cache expires after cache duration")
    func testCacheExpiresAfterDuration() throws {
        let context = try TestModelContainer.createContext()
        let cache = MovieListCache(modelContext: context)
        let movies = TestDataBuilder.makeSampleMovieList(count: 2)
        let response = MovieListResponse(page: 1, results: movies, totalPages: 1, totalResults: 2)
        
        try cache.saveMovies(response, page: 1)
        
        // Try with very short cache duration (0 seconds = already expired)
        let result = try cache.getMovies(page: 1, cacheDuration: 0)
        
        #expect(result == nil)
    }
    
    @Test("Cache handles multiple pages independently")
    func testCacheHandlesMultiplePages() throws {
        let context = try TestModelContainer.createContext()
        let cache = MovieListCache(modelContext: context)
        
        let page1Movies = TestDataBuilder.makeSampleMovieList(count: 3, baseTitle: "Page1")
        let page1Response = MovieListResponse(page: 1, results: page1Movies, totalPages: 2, totalResults: 6)
        try cache.saveMovies(page1Response, page: 1)
        
        let page2Movies = TestDataBuilder.makeSampleMovieList(count: 3, baseTitle: "Page2")
        let page2Response = MovieListResponse(page: 2, results: page2Movies, totalPages: 2, totalResults: 6)
        try cache.saveMovies(page2Response, page: 2)
        
        let result1 = try cache.getMovies(page: 1, cacheDuration: 3600)
        let result2 = try cache.getMovies(page: 2, cacheDuration: 3600)
        
        #expect(result1?.results.first?.title == "Page1 1")
        #expect(result2?.results.first?.title == "Page2 1")
    }
    
    @Test("Cache saves movies with correct metadata")
    func testCacheSavesCorrectMetadata() throws {
        let context = try TestModelContainer.createContext()
        let cache = MovieListCache(modelContext: context)
        let movies = TestDataBuilder.makeSampleMovieList(count: 2)
        let response = MovieListResponse(page: 3, results: movies, totalPages: 15, totalResults: 300)
        
        try cache.saveMovies(response, page: 3)
        let result = try cache.getMovies(page: 3, cacheDuration: 3600)
        
        #expect(result?.page == 3)
        #expect(result?.totalPages == 15)
        #expect(result?.totalResults == 300)
    }
    
    @Test("Cache clears all data successfully")
    func testCacheClearAll() throws {
        let context = try TestModelContainer.createContext()
        let cache = MovieListCache(modelContext: context)
        let movies = TestDataBuilder.makeSampleMovieList(count: 2)
        let response = MovieListResponse(page: 1, results: movies, totalPages: 1, totalResults: 2)
        
        try cache.saveMovies(response, page: 1)
        try cache.clearAll()
        let result = try cache.getMovies(page: 1, cacheDuration: 3600)
        
        #expect(result == nil)
    }
    
    @Test("Cache returns nil for non-existent page")
    func testCacheReturnsNilForNonExistentPage() throws {
        let context = try TestModelContainer.createContext()
        let cache = MovieListCache(modelContext: context)
        let movies = TestDataBuilder.makeSampleMovieList(count: 2)
        let response = MovieListResponse(page: 1, results: movies, totalPages: 1, totalResults: 2)
        
        try cache.saveMovies(response, page: 1)
        let result = try cache.getMovies(page: 2, cacheDuration: 3600)
        
        #expect(result == nil)
    }
}
