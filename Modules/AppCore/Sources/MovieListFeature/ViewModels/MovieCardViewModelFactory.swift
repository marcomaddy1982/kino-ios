//
//  MovieCardViewModelFactory.swift
//  Kino
//
//  Created by Marco Maddalena on 25.03.26.
//

import AppFeatures
import Foundation
import Models

@MainActor
public final class MovieCardViewModelFactory {
    @Injected<ImageServiceProtocol> var imageService

    public static func makeMovieCardViewModel(for movie: Movie) -> MovieCardViewModel {
        let factory = MovieCardViewModelFactory()
        return MovieCardViewModel(movie: movie, imageService: factory.imageService)
    }
}
