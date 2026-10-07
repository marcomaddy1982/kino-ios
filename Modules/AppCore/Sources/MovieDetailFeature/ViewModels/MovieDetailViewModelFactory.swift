//
//  MovieDetailViewModelFactory.swift
//  Kino
//
//  Created by Marco Maddalena on 25.03.26.
//

import AppFeatures
import Foundation
import Models

@MainActor
final class MovieDetailViewModelFactory {
    @Injected<MovieServiceProtocol> var movieService
    @Injected<ImageServiceProtocol> var imageService
    @Injected<RecentlyViewedRepositoryProtocol> var recentlyViewedRepository
    @Injected<ListsServiceProtocol> var listsService

    static func makeMovieDetailViewModel(for movie: Movie) -> MovieDetailViewModel {
        let factory = MovieDetailViewModelFactory()
        return MovieDetailViewModel(
            movie: movie,
            movieService: factory.movieService,
            imageService: factory.imageService,
            recentlyViewedRepository: factory.recentlyViewedRepository,
            listsService: factory.listsService
        )
    }
}
