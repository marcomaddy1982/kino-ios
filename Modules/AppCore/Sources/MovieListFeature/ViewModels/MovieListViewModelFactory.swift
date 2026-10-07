//
//  MovieListViewModelFactory.swift
//  Kino
//
//  Created by Marco Maddalena on 25.03.26.
//

import AppFeatures
import Foundation

@MainActor
final class MovieListViewModelFactory {
    @Injected<MovieRepositoryProtocol> var movieRepository
    @Injected<ImageServiceProtocol> var imageService

    static func makeMovieListViewModel() -> MovieListViewModel {
        let factory = MovieListViewModelFactory()
        return MovieListViewModel(
            movieRepository: factory.movieRepository,
            imageService: factory.imageService
        )
    }
}
