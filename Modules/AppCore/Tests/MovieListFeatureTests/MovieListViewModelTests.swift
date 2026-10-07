//
//  MovieListViewModelTests.swift
//  KinoTests
//
//  Created by Marco Maddalena on 23.03.26.
//

import Testing
import TestSupport
import Foundation
@testable import MovieListFeature

@Suite("MovieListViewModel Tests")
@MainActor
struct MovieListViewModelTests {
    
    @Test("Initial state is loading with default pagination values")
    func testInitialState() {
        let mockRepository = MockMovieRepository()
        let mockImageService = MockImageService()
        
        let sut = MovieListViewModel(movieRepository: mockRepository, imageService: mockImageService)

        if case .loading = sut.state {
            #expect(true)
        } else {
            Issue.record("Initial state should be .loading")
        }
        #expect(sut.currentPage == 1)
        #expect(sut.hasMorePages == true)
        #expect(sut.isPaginationLoading == false)
    }
    
    @Test("loadMovies succeeds and updates state to success")
    func testLoadMoviesSuccess() async {
        let mockRepository = MockMovieRepository()
        let mockImageService = MockImageService()
        let sampleResponse = TestDataBuilder.makeSampleDiscoverResponse(page: 1, totalPages: 10)
        mockRepository.setMockResponse(sampleResponse)
        
        let sut = MovieListViewModel(movieRepository: mockRepository, imageService: mockImageService)

        await sut.loadMovies()

        if case .success(let movies) = sut.state {
            #expect(movies.count == 5) // Default sample has 5 movies
        } else {
            Issue.record("State should be .success after loading")
        }
        #expect(sut.currentPage == 1)
        #expect(sut.hasMorePages == true)
        #expect(mockRepository.getMoviesCallCount == 1)
    }
    
    @Test("loadMovies handles errors and updates state to error")
    func testLoadMoviesError() async {
        let mockRepository = MockMovieRepository()
        let mockImageService = MockImageService()
        mockRepository.shouldThrowOnGet = true
        
        let sut = MovieListViewModel(movieRepository: mockRepository, imageService: mockImageService)

        await sut.loadMovies()

        if case .error(let message) = sut.state {
            #expect(message.contains("Failed to load movies"))
        } else {
            Issue.record("State should be .error after failure")
        }
    }
    
    @Test("loadNextPage appends movies to existing list")
    func testLoadNextPageAppendMovies() async {
        let mockRepository = MockMovieRepository()
        let mockImageService = MockImageService()
        let page1Response = TestDataBuilder.makeSampleDiscoverResponse(page: 1, totalPages: 3, results: TestDataBuilder.makeSampleMovieList(count: 5, baseTitle: "Page1"))
        mockRepository.setMockResponse(page1Response)
        
        let sut = MovieListViewModel(movieRepository: mockRepository, imageService: mockImageService)

        await sut.loadMovies()

        let page2Response = TestDataBuilder.makeSampleDiscoverResponse(page: 2, totalPages: 3, results: TestDataBuilder.makeSampleMovieList(count: 5, baseTitle: "Page2"))
        mockRepository.setMockResponse(page2Response)

        await sut.loadNextPage()

        if case .success(let movies) = sut.state {
            #expect(movies.count == 10) // 5 from page 1 + 5 from page 2
        } else {
            Issue.record("State should contain success with appended movies")
        }
        #expect(sut.currentPage == 2)
        #expect(mockRepository.getMoviesCallCount == 2)
    }
    
    @Test("loadNextPage updates pagination info")
    func testLoadNextPageUpdatesPaginationInfo() async {
        let mockRepository = MockMovieRepository()
        let mockImageService = MockImageService()
        let page1Response = TestDataBuilder.makeSampleDiscoverResponse(page: 1, totalPages: 3)
        mockRepository.setMockResponse(page1Response)
        
        let sut = MovieListViewModel(movieRepository: mockRepository, imageService: mockImageService)
        await sut.loadMovies()

        let lastPageResponse = TestDataBuilder.makeSampleDiscoverResponse(page: 3, totalPages: 3)
        mockRepository.setMockResponse(lastPageResponse)

        await sut.loadNextPage()
        await sut.loadNextPage()

        #expect(sut.currentPage == 3)
        #expect(sut.hasMorePages == false) // No more pages after page 3 of 3
    }
    
    @Test("loadNextPage guards when state is not success")
    func testLoadNextPageGuardsWhenNotSuccess() async {
        let mockRepository = MockMovieRepository()
        let mockImageService = MockImageService()
        mockRepository.shouldThrowOnGet = true
        
        let sut = MovieListViewModel(movieRepository: mockRepository, imageService: mockImageService)
        await sut.loadMovies() // Will result in .error state

        await sut.loadNextPage()

        #expect(mockRepository.getMoviesCallCount == 1) // Only from loadMovies
    }
    
    @Test("loadNextPage guards when no more pages available")
    func testLoadNextPageGuardsWhenNoMorePages() async {
        let mockRepository = MockMovieRepository()
        let mockImageService = MockImageService()
        let lastPageResponse = TestDataBuilder.makeSampleDiscoverResponse(page: 1, totalPages: 1)
        mockRepository.setMockResponse(lastPageResponse)
        
        let sut = MovieListViewModel(movieRepository: mockRepository, imageService: mockImageService)
        await sut.loadMovies() // Loads single page

        await sut.loadNextPage()

        #expect(mockRepository.getMoviesCallCount == 1) // Only from loadMovies
        #expect(sut.hasMorePages == false)
    }
    
    @Test("loadNextPage guards when already loading")
    func testLoadNextPageGuardsWhenAlreadyLoading() async {
        let mockRepository = MockMovieRepository()
        let mockImageService = MockImageService()
        let page1Response = TestDataBuilder.makeSampleDiscoverResponse(page: 1, totalPages: 2)
        mockRepository.setMockResponse(page1Response)

        let sut = MovieListViewModel(movieRepository: mockRepository, imageService: mockImageService)
        await sut.loadMovies()

        let page2Response = TestDataBuilder.makeSampleDiscoverResponse(page: 2, totalPages: 2)
        mockRepository.setMockResponse(page2Response)

        // Fire two concurrent calls — the first sets isPaginationLoading = true before its
        // first suspension point, so the second call hits the guard and returns early.
        async let first: Void = sut.loadNextPage()
        async let second: Void = sut.loadNextPage()
        _ = await (first, second)

        #expect(mockRepository.getMoviesCallCount == 2) // loadMovies + one loadNextPage
    }

    @Test("shouldLoadNextPage returns true for last movie with more pages")
    func testShouldLoadNextPageDetectsLastMovie() async {
        let mockRepository = MockMovieRepository()
        let mockImageService = MockImageService()
        let response = TestDataBuilder.makeSampleDiscoverResponse(
            page: 1, totalPages: 3,
            results: TestDataBuilder.makeSampleMovieList(count: 3)
        )
        mockRepository.setMockResponse(response)

        let sut = MovieListViewModel(movieRepository: mockRepository, imageService: mockImageService)
        await sut.loadMovies()

        guard case .success(let movies) = sut.state else {
            Issue.record("Expected success state"); return
        }

        #expect(sut.shouldLoadNextPage(for: movies.last!))
        #expect(!sut.shouldLoadNextPage(for: movies.first!))
    }

    @Test("shouldLoadNextPage returns false when no more pages")
    func testShouldLoadNextPageFalseWhenNoMorePages() async {
        let mockRepository = MockMovieRepository()
        let mockImageService = MockImageService()
        let response = TestDataBuilder.makeSampleDiscoverResponse(page: 1, totalPages: 1)
        mockRepository.setMockResponse(response)

        let sut = MovieListViewModel(movieRepository: mockRepository, imageService: mockImageService)
        await sut.loadMovies()

        guard case .success(let movies) = sut.state else {
            Issue.record("Expected success state"); return
        }

        #expect(!sut.shouldLoadNextPage(for: movies.last!))
    }
}
