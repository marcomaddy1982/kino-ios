//
//  RecentlyViewedMovie.swift
//  Kino
//
//  Created by Marco Maddalena on 27.03.26.
//

import Foundation
import Models
import SwiftData

@Model
public final class RecentlyViewedMovie {
    @Attribute(.unique) public var tmdbId: Int
    public var title: String
    public var posterPath: String?
    public var voteAverage: Double
    public var overview: String?
    public var releaseDate: String?
    public var viewedAtTimestamp: TimeInterval

    public init(from movie: Movie) {
        self.tmdbId = movie.tmdbId
        self.title = movie.title
        self.posterPath = movie.posterPath
        self.voteAverage = movie.voteAverage
        self.overview = movie.overview
        self.releaseDate = movie.releaseDate
        self.viewedAtTimestamp = Date().timeIntervalSince1970
    }

    public func toMovie() -> Movie {
        Movie(
            tmdbId: tmdbId,
            title: title,
            posterPath: posterPath,
            voteAverage: voteAverage,
            overview: overview,
            releaseDate: releaseDate
        )
    }
}
