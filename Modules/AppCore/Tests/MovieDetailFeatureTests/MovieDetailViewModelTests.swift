//
//  MovieDetailViewModelTests.swift
//  KinoTests
//
//  Created by Marco Maddalena on 24.03.26.
//

import Foundation
import Models
import Networking
import Testing
import TestSupport

@testable import MovieDetailFeature

@Suite("MovieDetailViewModel Tests")
@MainActor
struct MovieDetailViewModelTests {
    
    @Test("Initial state is loading")
    func testInitialState() {
        let testMovie = TestDataBuilder.makeSampleMovie(title: "Test Movie")
        let mockMovieService = MockMovieService()
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        
        if case .loading = sut.state {
            #expect(true)
        } else {
            Issue.record("Initial state should be .loading")
        }
    }
    
    // MARK: - Success Path Tests
    
    @Test("loadMovieDetail succeeds and updates state to success")
    func testLoadMovieDetailSuccess() async {
        let testMovie = TestDataBuilder.makeSampleMovie(title: "Test Movie")
        let mockMovieDetail = TestDataBuilder.makeSampleMovieDetail(
            title: "Test Movie Detail",
            backdropPath: "/backdrop.jpg",
            tagline: "Test tagline"
        )
        
        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailSuccess(with: mockMovieDetail)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        
        await sut.loadMovieDetail()
        
        if case .success = sut.state {
            #expect(true)
        } else {
            Issue.record("State should be .success after loading")
        }
        #expect(mockMovieService.fetchMovieDetailCallCount == 1)
    }
    
    @Test("loadMovieDetail exposes correct title property")
    func testTitleProperty() async {
        let testMovie = TestDataBuilder.makeSampleMovie()
        let mockMovieDetail = TestDataBuilder.makeSampleMovieDetail(title: "The Shawshank Redemption")
        
        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailSuccess(with: mockMovieDetail)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        await sut.loadMovieDetail()
        
        #expect(sut.title == "The Shawshank Redemption")
    }
    
    @Test("voteAverageFormatted formats to single decimal place")
    func testVoteAverageFormatted() async {
        let testMovie = TestDataBuilder.makeSampleMovie()
        let mockMovieDetail = TestDataBuilder.makeSampleMovieDetail(voteAverage: 8.567)
        
        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailSuccess(with: mockMovieDetail)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        await sut.loadMovieDetail()
        
        #expect(sut.voteAverageFormatted == "8.6")
    }
    
    @Test("releaseDate formats correctly")
    func testReleaseDate() async {
        let testMovie = TestDataBuilder.makeSampleMovie()
        let mockMovieDetail = TestDataBuilder.makeSampleMovieDetail(releaseDate: "1994-09-23")
        
        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailSuccess(with: mockMovieDetail)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        await sut.loadMovieDetail()
        
        #expect(!sut.releaseDate.isEmpty)
        #expect(sut.releaseDate != "N/A")
    }
    
    @Test("runtime returns formatted string")
    func testRuntime() async {
        let testMovie = TestDataBuilder.makeSampleMovie()
        let mockMovieDetail = TestDataBuilder.makeSampleMovieDetail(runtime: 142)
        
        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailSuccess(with: mockMovieDetail)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        await sut.loadMovieDetail()
        
        #expect(!sut.runtime.isEmpty)
    }
    
    @Test("overview returns description or fallback message")
    func testOverview() async {
        let testMovie = TestDataBuilder.makeSampleMovie()
        let mockMovieDetail = TestDataBuilder.makeSampleMovieDetail(overview: "A detailed overview")
        
        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailSuccess(with: mockMovieDetail)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        await sut.loadMovieDetail()
        
        #expect(sut.overview == "A detailed overview")
    }
    
    @Test("overview returns fallback message when nil")
    func testOverviewFallback() async {
        let testMovie = TestDataBuilder.makeSampleMovie()
        let mockMovieDetail = TestDataBuilder.makeSampleMovieDetail(overview: nil)
        
        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailSuccess(with: mockMovieDetail)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        await sut.loadMovieDetail()
        
        #expect(sut.overview == "No overview available")
    }
    
    @Test("tagline returns value or empty string")
    func testTagline() async {
        let testMovie = TestDataBuilder.makeSampleMovie()
        let mockMovieDetail = TestDataBuilder.makeSampleMovieDetail(tagline: "A good tagline")
        
        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailSuccess(with: mockMovieDetail)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        await sut.loadMovieDetail()
        
        #expect(sut.tagline == "A good tagline")
    }
    
    @Test("backdropImageURL constructs URL with w780 size")
    func testBackdropImageURLConstruction() async {
        let testMovie = TestDataBuilder.makeSampleMovie()
        let mockMovieDetail = TestDataBuilder.makeSampleMovieDetail(backdropPath: "/test-backdrop.jpg")
        
        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailSuccess(with: mockMovieDetail)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        await sut.loadMovieDetail()
        
        #expect(sut.backdropImageURL != nil)
    }
    
    @Test("backdropImageURL returns nil when backdropPath is missing")
    func testBackdropImageURLNilWhenNoPath() async {
        let testMovie = TestDataBuilder.makeSampleMovie()
        let mockMovieDetail = TestDataBuilder.makeSampleMovieDetail(backdropPath: nil)
        
        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailSuccess(with: mockMovieDetail)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        await sut.loadMovieDetail()
        
        #expect(sut.backdropImageURL == nil)
    }
    
    @Test("hasBackdrop returns true when backdropPath exists")
    func testHasBackdropTrue() async {
        let testMovie = TestDataBuilder.makeSampleMovie()
        let mockMovieDetail = TestDataBuilder.makeSampleMovieDetail(backdropPath: "/backdrop.jpg")
        
        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailSuccess(with: mockMovieDetail)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        await sut.loadMovieDetail()
        
        #expect(sut.hasBackdrop == true)
    }
    
    @Test("hasTagline returns true when tagline exists and is not empty")
    func testHasTaglineTrue() async {
        let testMovie = TestDataBuilder.makeSampleMovie()
        let mockMovieDetail = TestDataBuilder.makeSampleMovieDetail(tagline: "A tagline")
        
        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailSuccess(with: mockMovieDetail)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        await sut.loadMovieDetail()
        
        #expect(sut.hasTagline == true)
    }
    
    @Test("hasGenres returns true when genres array is not empty")
    func testHasGenresTrue() async {
        let testMovie = TestDataBuilder.makeSampleMovie()
        let genres = TestDataBuilder.makeSampleGenres(count: 2)
        let mockMovieDetail = TestDataBuilder.makeSampleMovieDetail(genres: genres)
        
        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailSuccess(with: mockMovieDetail)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        await sut.loadMovieDetail()
        
        #expect(sut.hasGenres == true)
        #expect(sut.genres.count == 2)
    }
    
    @Test("hasFinancialInfo returns true when budget or revenue greater than 0")
    func testHasFinancialInfoTrue() async {
        let testMovie = TestDataBuilder.makeSampleMovie()
        let mockMovieDetail = TestDataBuilder.makeSampleMovieDetail(budget: 1000000, revenue: 5000000)
        
        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailSuccess(with: mockMovieDetail)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        await sut.loadMovieDetail()
        
        #expect(sut.hasFinancialInfo == true)
    }
    
    @Test("hasProductionCompanies returns true when array not empty")
    func testHasProductionCompaniesTrue() async {
        let testMovie = TestDataBuilder.makeSampleMovie()
        let companies = TestDataBuilder.makeSampleProductionCompanies(count: 1)
        let mockMovieDetail = TestDataBuilder.makeSampleMovieDetail(productionCompanies: companies)
        
        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailSuccess(with: mockMovieDetail)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        await sut.loadMovieDetail()
        
        #expect(sut.hasProductionCompanies == true)
    }
    
    @Test("hasProductionCountries returns true when array not empty")
    func testHasProductionCountriesTrue() async {
        let testMovie = TestDataBuilder.makeSampleMovie()
        let countries = TestDataBuilder.makeSampleProductionCountries(count: 1)
        let mockMovieDetail = TestDataBuilder.makeSampleMovieDetail(productionCountries: countries)
        
        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailSuccess(with: mockMovieDetail)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        await sut.loadMovieDetail()
        
        #expect(sut.hasProductionCountries == true)
    }
    
    @Test("hasSpokenLanguages returns true when array not empty")
    func testHasSpokenLanguagesTrue() async {
        let testMovie = TestDataBuilder.makeSampleMovie()
        let languages = TestDataBuilder.makeSampleSpokenLanguages(count: 1)
        let mockMovieDetail = TestDataBuilder.makeSampleMovieDetail(spokenLanguages: languages)
        
        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailSuccess(with: mockMovieDetail)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        await sut.loadMovieDetail()
        
        #expect(sut.hasSpokenLanguages == true)
    }
    
    // MARK: - Error Path Tests
    
    @Test("loadMovieDetail handles errors and updates state to error")
    func testLoadMovieDetailError() async {
        let testMovie = TestDataBuilder.makeSampleMovie()
        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailFailure(with: NetworkError.noData)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()
        
        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        
        await sut.loadMovieDetail()
        
        if case .error(let message) = sut.state {
            #expect(message.contains("Failed to load movie details"))
        } else {
            Issue.record("State should be .error after failure")
        }
    }
    
    @Test("loadMovieDetail calls service with correct movie ID")
    func testLoadMovieDetailCallsServiceWithCorrectId() async {
        let testMovie = TestDataBuilder.makeSampleMovie(tmdbId: 12345)
        let mockMovieDetail = TestDataBuilder.makeSampleMovieDetail()

        let mockMovieService = MockMovieService()
        mockMovieService.simulateDetailSuccess(with: mockMovieDetail)
        let mockImageService = MockImageService()
        let mockRecentlyViewedRepository = MockRecentlyViewedRepository()

        let sut = MovieDetailViewModel(movie: testMovie, movieService: mockMovieService, imageService: mockImageService, recentlyViewedRepository: mockRecentlyViewedRepository, listsService: MockListsService())
        await sut.loadMovieDetail()

        #expect(mockMovieService.lastMovieIdRequested == 12345)
    }

    // MARK: - Favourite Tests

    @Test("loadFavouriteState sets isFavourite to true when movie is in favourites")
    func testLoadFavouriteStateTrue() async {
        let testMovie = TestDataBuilder.makeSampleMovie(tmdbId: 550)
        let mockListsService = MockListsService()
        mockListsService.mockIsFavourite = true

        let sut = MovieDetailViewModel(
            movie: testMovie,
            movieService: MockMovieService(),
            imageService: MockImageService(),
            recentlyViewedRepository: MockRecentlyViewedRepository(),
            listsService: mockListsService
        )
        await sut.loadFavouriteState()

        #expect(sut.isFavourite == true)
        #expect(mockListsService.lastCheckedTmdbMovieId == 550)
    }

    @Test("loadFavouriteState sets isFavourite to false when movie is not in favourites")
    func testLoadFavouriteStateFalse() async {
        let testMovie = TestDataBuilder.makeSampleMovie(tmdbId: 550)
        let mockListsService = MockListsService()
        mockListsService.mockIsFavourite = false

        let sut = MovieDetailViewModel(
            movie: testMovie,
            movieService: MockMovieService(),
            imageService: MockImageService(),
            recentlyViewedRepository: MockRecentlyViewedRepository(),
            listsService: mockListsService
        )
        await sut.loadFavouriteState()

        #expect(sut.isFavourite == false)
    }

    @Test("loadFavouriteState silently fails and defaults to false on error")
    func testLoadFavouriteStateHandlesError() async {
        let testMovie = TestDataBuilder.makeSampleMovie()
        let mockListsService = MockListsService()
        mockListsService.error = NetworkError.noData

        let sut = MovieDetailViewModel(
            movie: testMovie,
            movieService: MockMovieService(),
            imageService: MockImageService(),
            recentlyViewedRepository: MockRecentlyViewedRepository(),
            listsService: mockListsService
        )
        await sut.loadFavouriteState()

        #expect(sut.isFavourite == false)
    }

    @Test("toggleFavourite updates isFavourite with service result")
    func testToggleFavourite() async {
        let testMovie = TestDataBuilder.makeSampleMovie(tmdbId: 550)
        let mockListsService = MockListsService()
        mockListsService.mockToggleResult = true

        let sut = MovieDetailViewModel(
            movie: testMovie,
            movieService: MockMovieService(),
            imageService: MockImageService(),
            recentlyViewedRepository: MockRecentlyViewedRepository(),
            listsService: mockListsService
        )
        await sut.toggleFavourite()

        #expect(sut.isFavourite == true)
        #expect(mockListsService.lastToggledTmdbMovieId == 550)
    }
}
