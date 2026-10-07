//
//  SearchViewModel.swift
//  Kino
//
//  Created by Marco Maddalena on 24.03.26.
//

import AppFeatures
import Combine
import Foundation
import Models
import Observation

enum SearchViewState: Sendable {
    case empty
    case loading
    case success([Movie])
    case error(String)
}

@Observable
final class SearchViewModel {
    var searchQuery: String = "" {
        didSet { searchQuerySubject.send(searchQuery) }
    }
    var searchResults: [Movie] = []
    var state: SearchViewState = .empty
    private(set) var currentPage: Int = 1
    private(set) var hasMorePages: Bool = false
    private(set) var isPaginationLoading: Bool = false

    private let searchService: SearchServiceProtocol
    let imageService: ImageServiceProtocol

    private let searchQuerySubject = PassthroughSubject<String, Never>()
    private var cancellables: Set<AnyCancellable> = []

    init(searchService: SearchServiceProtocol, imageService: ImageServiceProtocol) {
        self.searchService = searchService
        self.imageService = imageService
        setupSearchPipeline()
    }
    
    // MARK: - Public Methods

    func performSearch(query: String) {
        isPaginationLoading = false
        currentPage = 1
        searchResults = []
        hasMorePages = false
        state = .loading

        Task {
            await executeSearch(query: query, page: 1)
        }
    }

    func loadNextPage() {
        guard !isPaginationLoading, hasMorePages else { return }
        
        isPaginationLoading = true
        let nextPage = currentPage + 1
        
        Task {
            await executeSearch(
                query: searchQuery,
                page: nextPage,
                isPagination: true
            )
        }
    }

    func shouldLoadNextPage(for movie: Movie) -> Bool {
        guard let lastMovie = searchResults.last else { return false }
        return movie.id == lastMovie.id && hasMorePages
    }
    
    // MARK: - Private Methods

    private func setupSearchPipeline() {
        // Pipeline 1: Handle valid searches (debounced)
        searchQuerySubject
            .filter { !$0.isEmpty }
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)

        // Pipeline 2: Handle empty queries (user taps X button)
        searchQuerySubject
            .filter { $0.isEmpty }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.clearSearchState()
            }
            .store(in: &cancellables)
    }

    private func executeSearch(query: String, page: Int, isPagination: Bool = false) async {
        do {
            let response = try await searchService.searchMovies(query: query, page: page)

            if isPagination {
                searchResults.append(contentsOf: response.results)
                isPaginationLoading = false
            } else {
                searchResults = response.results
            }

            currentPage = page
            hasMorePages = page < response.totalPages
            state = .success(searchResults)
        } catch {
            state = .error(error.localizedDescription)
            isPaginationLoading = false
        }
    }

    private func clearSearchState() {
        searchResults = []
        currentPage = 1
        hasMorePages = false
        isPaginationLoading = false
        state = .empty
     }
}
