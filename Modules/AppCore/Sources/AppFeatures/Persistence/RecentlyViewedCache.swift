//
//  RecentlyViewedCache.swift
//  Kino
//
//  Created by Marco Maddalena on 27.03.26.
//

import SwiftData
import Foundation

@MainActor
public final class RecentlyViewedCache {
    public let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func getRecentlyViewed() throws -> [RecentlyViewedMovie] {
        let descriptor = FetchDescriptor<RecentlyViewedMovie>(
            sortBy: [SortDescriptor(\.viewedAtTimestamp, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func saveMovie(_ movie: RecentlyViewedMovie) throws {
        modelContext.insert(movie)
        try modelContext.save()
    }

    public func clearAll() throws {
        try modelContext.delete(model: RecentlyViewedMovie.self)
    }
}
