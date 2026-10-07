//
//  Movie.swift
//  Kino
//
//  Created by Marco Maddalena on 23.03.26.
//

import Foundation

public nonisolated struct Movie: Codable, Sendable, Identifiable, Equatable, Hashable {
    public let id: UUID
    public let tmdbId: Int
    public let title: String
    public let posterPath: String?
    public let voteAverage: Double
    public let overview: String?
    public let releaseDate: String?
    
    public init(id: UUID = UUID(), tmdbId: Int, title: String, posterPath: String?, voteAverage: Double, overview: String?, releaseDate: String?) {
        self.id = id
        self.tmdbId = tmdbId
        self.title = title
        self.posterPath = posterPath
        self.voteAverage = voteAverage
        self.overview = overview
        self.releaseDate = releaseDate
    }
    
    enum CodingKeys: String, CodingKey {
        case title, overview
        case tmdbId = "id"
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
    }
    
    // Ignore UUID id during decoding since it's generated fresh for each instance
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.tmdbId = try container.decode(Int.self, forKey: .tmdbId)
        self.title = try container.decode(String.self, forKey: .title)
        self.posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        self.voteAverage = try container.decode(Double.self, forKey: .voteAverage)
        self.overview = try container.decodeIfPresent(String.self, forKey: .overview)
        self.releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
    }
    
    // Custom encoding to exclude UUID id, but include tmdbId
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tmdbId, forKey: .tmdbId)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(posterPath, forKey: .posterPath)
        try container.encode(voteAverage, forKey: .voteAverage)
        try container.encodeIfPresent(overview, forKey: .overview)
        try container.encodeIfPresent(releaseDate, forKey: .releaseDate)
    }
}
