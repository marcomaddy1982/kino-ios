//
//  RecentlyViewedRepository.swift
//  Kino
//
//  Created by Marco Maddalena on 27.03.26.
//

import Foundation
import Models

public protocol RecentlyViewedRepositoryProtocol {
    func getRecentlyViewed() async throws -> [Movie]
    func saveMovie(_ movie: Movie) async throws
    func clearAll() async throws
}

@MainActor
public final class RecentlyViewedRepository: RecentlyViewedRepositoryProtocol {
    @Injected<RecentlyViewedCache> var recentlyViewedCache: RecentlyViewedCache

    public init() {}

    public func getRecentlyViewed() async throws -> [Movie] {
        let recentlyViewedMovies = try recentlyViewedCache.getRecentlyViewed()
        return recentlyViewedMovies.map { $0.toMovie() }
    }

    public func saveMovie(_ movie: Movie) async throws {
        let recentlyViewedMovie = RecentlyViewedMovie(from: movie)
        try recentlyViewedCache.saveMovie(recentlyViewedMovie)
    }

    public func clearAll() async throws {
        try recentlyViewedCache.clearAll()
    }
}
