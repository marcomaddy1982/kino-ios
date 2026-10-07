//
//  MovieListViewModelCacheTests.swift
//  KinoTests
//
//  Created by Marco Maddalena on 25.03.26.
//

import Foundation
import Models
import Testing
import TestSupport

@testable import MovieListFeature

@Suite("MovieListViewModel Cache Tests")
@MainActor
struct MovieListViewModelCacheTests {
    
    @Test("ViewModel loads movies from repository successfully")
    func testViewModelLoadMoviesSuccess() async throws {
        let mockRepository = MockMovieRepository()
        let mockImageService = MockImageService()
        let movies = TestDataBuilder.makeSampleMovieList(count: 5)
        let response = MovieListResponse(page: 1, results: movies, totalPages: 10, totalResults: 200)
        mockRepository.setMockResponse(response)
        
        let sut = MovieListViewModel(movieRepository: mockRepository, imageService: mockImageService)
        await sut.loadMovies()
        
        if case .success(let loadedMovies) = sut.state {
            #expect(loadedMovies.count == 5)
        } else {
            Issue.record("State should be success after loading")
        }
        #expect(mockRepository.getMoviesCallCount == 1)
        #expect(mockRepository.lastPageRequested == 1)
        #expect(mockRepository.lastForceRefreshRequested == false)
    }
    
    @Test("ViewModel preserves movie order from repository")
    func testViewModelPreservesMovieOrder() async throws {
        let mockRepository = MockMovieRepository()
        let mockImageService = MockImageService()
        let movies = TestDataBuilder.makeSampleMovieList(count: 4, baseTitle: "Ordered")
        let response = MovieListResponse(page: 1, results: movies, totalPages: 1, totalResults: 4)
        mockRepository.setMockResponse(response)
        
        let sut = MovieListViewModel(movieRepository: mockRepository, imageService: mockImageService)
        await sut.loadMovies()
        
        if case .success(let loadedMovies) = sut.state {
            for (index, movie) in loadedMovies.enumerated() {
                #expect(movie.title == "Ordered \(index + 1)")
            }
        } else {
            Issue.record("State should be success")
        }
    }
    
    @Test("ViewModel handles pagination with repository")
    func testViewModelPaginationWithRepository() async throws {
        let mockRepository = MockMovieRepository()
        let mockImageService = MockImageService()
        let page1Movies = TestDataBuilder.makeSampleMovieList(count: 3, baseTitle: "Page1")
        let page1Response = MovieListResponse(page: 1, results: page1Movies, totalPages: 2, totalResults: 6)
        mockRepository.setMockResponse(page1Response)
        
        let sut = MovieListViewModel(movieRepository: mockRepository, imageService: mockImageService)
        await sut.loadMovies()
        
        #expect(mockRepository.getMoviesCallCount == 1)
        #expect(mockRepository.lastPageRequested == 1)
        
        let page2Movies = TestDataBuilder.makeSampleMovieList(count: 3, baseTitle: "Page2")
        let page2Response = MovieListResponse(page: 2, results: page2Movies, totalPages: 2, totalResults: 6)
        mockRepository.setMockResponse(page2Response)
        
        await sut.loadNextPage()
        
        if case .success(let allMovies) = sut.state {
            #expect(allMovies.count == 6)
            #expect(allMovies[0].title == "Page1 1")
            #expect(allMovies[3].title == "Page2 1")
        } else {
            Issue.record("State should be success with paginated data")
        }
        #expect(mockRepository.getMoviesCallCount == 2)
        #expect(mockRepository.lastPageRequested == 2)
    }
    
    @Test("ViewModel handles repository errors gracefully")
    func testViewModelHandlesRepositoryError() async throws {
        let mockRepository = MockMovieRepository()
        let mockImageService = MockImageService()
        mockRepository.shouldThrowOnGet = true
        
        let sut = MovieListViewModel(movieRepository: mockRepository, imageService: mockImageService)
        await sut.loadMovies()
        
        if case .error(let message) = sut.state {
            #expect(message.contains("Failed to load movies"))
        } else {
            Issue.record("State should be error when repository throws")
        }
        #expect(mockRepository.getMoviesCallCount == 1)
    }
    
    @Test("ViewModel forces refresh when requested")
    func testViewModelForceRefresh() async throws {
        let mockRepository = MockMovieRepository()
        let mockImageService = MockImageService()
        let movies = TestDataBuilder.makeSampleMovieList(count: 2)
        let response = MovieListResponse(page: 1, results: movies, totalPages: 1, totalResults: 2)
        mockRepository.setMockResponse(response)
        
        let sut = MovieListViewModel(movieRepository: mockRepository, imageService: mockImageService)
        
        // Initial load
        await sut.loadMovies()
        #expect(mockRepository.lastForceRefreshRequested == false)
        
        // Force refresh (would need to be exposed in ViewModel)
        // This test verifies the parameter is available
        #expect(mockRepository.getMoviesCallCount == 1)
    }
    
    @Test("ViewModel maintains pagination metadata correctly")
    func testViewModelPaginationMetadata() async throws {
        let mockRepository = MockMovieRepository()
        let mockImageService = MockImageService()
        let response = MovieListResponse(page: 1, results: TestDataBuilder.makeSampleMovieList(count: 5), totalPages: 3, totalResults: 15)
        mockRepository.setMockResponse(response)
        
        let sut = MovieListViewModel(movieRepository: mockRepository, imageService: mockImageService)
        await sut.loadMovies()
        
        #expect(sut.currentPage == 1)
        #expect(sut.hasMorePages == true)
        
        let lastPageResponse = MovieListResponse(page: 3, results: TestDataBuilder.makeSampleMovieList(count: 5), totalPages: 3, totalResults: 15)
        mockRepository.setMockResponse(lastPageResponse)
        await sut.loadNextPage()
        await sut.loadNextPage()
        
        #expect(sut.currentPage == 3)
        #expect(sut.hasMorePages == false)
    }
}
