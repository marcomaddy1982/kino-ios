//
//  SearchViewModelTests.swift
//  KinoTests
//
//  Created by Marco Maddalena on 25.03.26.
//

import Testing
import TestSupport
import Foundation
import Networking
@testable import SearchFeature

@Suite("SearchViewModel Tests")
@MainActor
struct SearchViewModelTests {

    func makeSUT() -> (SearchViewModel, MockSearchService) {
        let mockSearchService = MockSearchService()
        let mockImageService = MockImageService()
        let sut = SearchViewModel(searchService: mockSearchService, imageService: mockImageService)
        return (sut, mockSearchService)
    }

    // MARK: - Initial State

    @Test("Initial state is empty")
    func testInitialStateIsEmpty() {
        let (sut, _) = makeSUT()
        if case .empty = sut.state { #expect(true) } else { Issue.record("Initial state should be .empty") }
    }

    @Test("Initial pagination values are correct")
    func testInitialPaginationValues() {
        let (sut, _) = makeSUT()
        #expect(sut.currentPage == 1)
        #expect(sut.hasMorePages == false)
        #expect(sut.isPaginationLoading == false)
        #expect(sut.searchQuery.isEmpty)
        #expect(sut.searchResults.isEmpty)
    }

    // MARK: - Search Tests

    @Test("Search succeeds and updates state to success")
    func testSearchSucceeds() async {
        let (sut, mockSearchService) = makeSUT()
        let response = TestDataBuilder.makeSampleMovieListResponse(page: 1, totalPages: 5, results: TestDataBuilder.makeSampleMovieList(count: 10))
        mockSearchService.simulateSuccess(with: response)

        sut.performSearch(query: "Test")
        await Task.yield()
        await Task.yield()

        if case .success(let movies) = sut.state {
            #expect(movies.count == 10)
        } else {
            Issue.record("State should be .success after search")
        }
    }

    @Test("Search failure updates error state")
    func testSearchFailureUpdatesErrorState() async {
        let (sut, mockSearchService) = makeSUT()
        mockSearchService.simulateFailure(with: NetworkError.noData)

        sut.performSearch(query: "Test")
        await Task.yield()
        await Task.yield()

        if case .error(let message) = sut.state {
            #expect(!message.isEmpty)
        } else {
            Issue.record("State should be .error after search failure")
        }
    }

    @Test("Error state contains error message")
    func testErrorStateContainsMessage() async {
        let (sut, mockSearchService) = makeSUT()
        mockSearchService.simulateFailure(with: NetworkError.noData)

        sut.performSearch(query: "Test")
        await Task.yield()
        await Task.yield()

        if case .error(let message) = sut.state {
            #expect(!message.isEmpty)
        } else {
            Issue.record("State should be .error")
        }
    }

    @Test("Search updates hasMorePages correctly")
    func testSearchUpdatesHasMorePages() async {
        let (sut, mockSearchService) = makeSUT()
        mockSearchService.simulateSuccess(with: TestDataBuilder.makeSampleMovieListResponse(page: 1, totalPages: 5))

        sut.performSearch(query: "Test")
        await Task.yield()
        await Task.yield()

        #expect(sut.currentPage == 1)
        #expect(sut.hasMorePages == true)
    }

    @Test("Search resets results on new query")
    func testSearchResetsResultsOnNewQuery() async {
        let (sut, mockSearchService) = makeSUT()
        mockSearchService.simulateSuccess(with: TestDataBuilder.makeSampleMovieListResponse(results: TestDataBuilder.makeSampleMovieList(count: 5, baseTitle: "Query1")))

        sut.performSearch(query: "Query1")
        await Task.yield()
        await Task.yield()

        if case .success(let movies) = sut.state { #expect(movies.count == 5) }

        mockSearchService.simulateSuccess(with: TestDataBuilder.makeSampleMovieListResponse(results: TestDataBuilder.makeSampleMovieList(count: 3, baseTitle: "Query2")))
        sut.performSearch(query: "Query2")
        await Task.yield()
        await Task.yield()

        if case .success(let movies) = sut.state {
            #expect(movies.count == 3)
        } else {
            Issue.record("State should be .success after second search")
        }
    }

    @Test("Empty query resets state to empty")
    func testEmptyQueryResetsState() async {
        let (sut, mockSearchService) = makeSUT()
        mockSearchService.simulateSuccess(with: TestDataBuilder.makeSampleMovieListResponse())

        sut.performSearch(query: "Test")
        await Task.yield()
        await Task.yield()

        if case .success = sut.state { #expect(true) } else { Issue.record("State should be success after search") }

        sut.searchQuery = ""
        await Task.yield()

        if case .empty = sut.state { #expect(true) } else { Issue.record("State should be empty after clearing query") }
    }

    @Test("Empty query clears results")
    func testEmptyQueryClearsResults() async {
        let (sut, mockSearchService) = makeSUT()
        mockSearchService.simulateSuccess(with: TestDataBuilder.makeSampleMovieListResponse())

        sut.performSearch(query: "Test")
        await Task.yield()
        await Task.yield()

        #expect(!sut.searchResults.isEmpty)

        sut.searchQuery = ""
        await Task.yield()

        #expect(sut.searchResults.isEmpty)
    }

    // MARK: - Pagination Tests

    @Test("Load next page appends results")
    func testLoadNextPageAppendsResults() async {
        let (sut, mockSearchService) = makeSUT()
        mockSearchService.simulateSuccess(with: TestDataBuilder.makeSampleMovieListResponse(page: 1, totalPages: 3, results: TestDataBuilder.makeSampleMovieList(count: 5, baseTitle: "Page1")))

        sut.performSearch(query: "Test")
        await Task.yield()
        await Task.yield()

        if case .success(let movies) = sut.state { #expect(movies.count == 5) }

        mockSearchService.simulateSuccess(with: TestDataBuilder.makeSampleMovieListResponse(page: 2, totalPages: 3, results: TestDataBuilder.makeSampleMovieList(count: 5, baseTitle: "Page2")))
        sut.loadNextPage()
        await Task.yield()
        await Task.yield()

        if case .success(let movies) = sut.state {
            #expect(movies.count == 10)
        } else {
            Issue.record("State should still be success after pagination")
        }
    }

    @Test("Load next page updates current page")
    func testLoadNextPageUpdatesCurrentPage() async {
        let (sut, mockSearchService) = makeSUT()
        mockSearchService.simulateSuccess(with: TestDataBuilder.makeSampleMovieListResponse(page: 1, totalPages: 3))

        sut.performSearch(query: "Test")
        await Task.yield()
        await Task.yield()

        #expect(sut.currentPage == 1)

        mockSearchService.simulateSuccess(with: TestDataBuilder.makeSampleMovieListResponse(page: 2, totalPages: 3))
        sut.loadNextPage()
        await Task.yield()
        await Task.yield()

        #expect(sut.currentPage == 2)
    }

    @Test("Load next page guards when no more pages")
    func testLoadNextPageGuardsWhenNoMorePages() async {
        let (sut, mockSearchService) = makeSUT()
        mockSearchService.simulateSuccess(with: TestDataBuilder.makeSampleMovieListResponse(page: 1, totalPages: 1))

        sut.performSearch(query: "Test")
        await Task.yield()
        await Task.yield()

        #expect(sut.hasMorePages == false)

        let callCountBefore = mockSearchService.searchMoviesCallCount
        sut.loadNextPage()

        #expect(mockSearchService.searchMoviesCallCount == callCountBefore)
    }

    @Test("shouldLoadNextPage returns false when no more pages")
    func testShouldLoadNextPageReturnsFalseWhenNoMorePages() async {
        let (sut, mockSearchService) = makeSUT()
        mockSearchService.simulateSuccess(with: TestDataBuilder.makeSampleMovieListResponse(page: 1, totalPages: 1))

        sut.performSearch(query: "Test")
        await Task.yield()
        await Task.yield()

        guard case .success(let movies) = sut.state, let last = movies.last else { return }
        #expect(!sut.shouldLoadNextPage(for: last))
    }

    @Test("shouldLoadNextPage detects last movie")
    func testShouldLoadNextPageDetectsLastMovie() async {
        let (sut, mockSearchService) = makeSUT()
        let movies = TestDataBuilder.makeSampleMovieList(count: 3)
        mockSearchService.simulateSuccess(with: TestDataBuilder.makeSampleMovieListResponse(page: 1, totalPages: 3, results: movies))

        sut.performSearch(query: "Test")
        await Task.yield()
        await Task.yield()

        #expect(sut.shouldLoadNextPage(for: movies.last!))
        #expect(!sut.shouldLoadNextPage(for: movies.first!))
    }
}
