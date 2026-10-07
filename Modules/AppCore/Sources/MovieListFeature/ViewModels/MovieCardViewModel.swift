//
//  MovieCardViewModel.swift
//  NeuGelbTest
//
//  Created by Marco Maddalena on 23.03.26.
//

import AppFeatures
import Foundation
import Models
import Observation
import SwiftUI
import os

enum ImageLoadingState {
    case idle
    case loading
    case success(Image)
    case error(String)
}

@Observable
public final class MovieCardViewModel {
    var imageState: ImageLoadingState = .idle
    let movie: Movie
    var title: String { movie.title }
    var releaseDate: String {
        guard let dateString = movie.releaseDate, !dateString.isEmpty else {
            return String(localized: "common.toBeAnnounced", bundle: .module)
        }
        return dateString.toMonthDayYearString() ?? String(localized: "common.toBeAnnounced", bundle: .module)
    }
    var voteAverage: String { String(format: "%.1f", movie.voteAverage) }
    var posterPath: String? { movie.posterPath }

    private let imageService: any ImageServiceProtocol
    private var imageLoadTask: Task<Void, Never>?

    public init(movie: Movie, imageService: any ImageServiceProtocol) {
        self.movie = movie
        self.imageService = imageService
    }
    
    func loadImage() {
        imageLoadTask?.cancel()
        
        guard let posterPath else {
            imageState = .idle
            return
        }
        
        imageLoadTask = Task {
            imageState = .loading
            
            if let image = await imageService.loadImage(from: posterPath) {
                if !Task.isCancelled {
                    imageState = .success(image)
                }
            } else {
                if !Task.isCancelled {
                    imageState = .error(String(localized: "common.failedToLoadPoster", bundle: .module))
                }
            }
        }
    }
    
    func cancelImageLoad() {
        imageLoadTask?.cancel()
        imageLoadTask = nil
    }
}
