//
//  MovieListViewModel.swift
//  Kino
//
//  Created by Marco Maddalena on 23.03.26.
//

import AppFeatures
import Foundation
import Models
import Observation
import os

enum ViewState: Equatable {
    case loading
    case success([Movie])
    case error(String)
}

@Observable
@MainActor
final class MovieListViewModel {
    var state: ViewState = .loading
    private(set) var isPaginationLoading: Bool = false
    private(set) var currentPage: Int = 1
    private(set) var hasMorePages: Bool = true

    private let movieRepository: MovieRepositoryProtocol
    private let imageService: ImageServiceProtocol

    init(movieRepository: MovieRepositoryProtocol, imageService: ImageServiceProtocol) {
        self.movieRepository = movieRepository
        self.imageService = imageService
    }
    
    func loadMovies(forceRefresh: Bool = false) async {
        state = .loading
        
        do {
            let response = try await movieRepository.getMovies(page: 1, forceRefresh: forceRefresh)
            self.state = .success(response.results)
            self.currentPage = response.page
            self.hasMorePages = response.page < response.totalPages
            print("🎬 Loaded page 1: \(response.results.count) movies")
        } catch {
            let errorMessage = "Failed to load movies: \(error.localizedDescription)"
            self.state = .error(errorMessage)
            print("❌ Failed to load movies: \(error.localizedDescription)")
        }
    }
    
    func loadNextPage(forceRefresh: Bool = false) async {
        guard hasMorePages && !isPaginationLoading else { return }
        guard case .success(var movies) = state else { return }
        
        isPaginationLoading = true
        let nextPage = currentPage + 1
        
        do {
            let response = try await movieRepository.getMovies(page: nextPage, forceRefresh: forceRefresh)
            movies.append(contentsOf: response.results)
            self.state = .success(movies)
            self.currentPage = response.page
            self.hasMorePages = response.page < response.totalPages
            print("🎬 Loaded page \(nextPage): \(response.results.count) more movies")
        } catch {
            print("❌ Failed to load page \(nextPage): \(error.localizedDescription)")
        }
        
        isPaginationLoading = false
    }
    
    func shouldLoadNextPage(for movie: Movie) -> Bool {
        guard case .success(let movies) = state,
              let lastMovie = movies.last else { return false }
        return movie.id == lastMovie.id && hasMorePages && !isPaginationLoading
    }
    
    func makeCardViewModel(for movie: Movie) -> MovieCardViewModel {
        MovieCardViewModelFactory.makeMovieCardViewModel(for: movie)
    }
}
