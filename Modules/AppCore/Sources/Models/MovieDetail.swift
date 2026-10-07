//
//  MovieDetail.swift
//  Kino
//
//  Created by Marco Maddalena on 24.03.26.
//

import Foundation

public nonisolated struct MovieDetail: Codable, Sendable {
    public let tmdbId: Int
    public let title: String
    public let overview: String?
    public let backdropPath: String?
    public let posterPath: String?
    public let voteAverage: Double
    public let releaseDate: String?
    public let runtime: Int?
    public let tagline: String?
    public let budget: Int
    public let revenue: Int
    public let genres: [Genre]
    public let productionCompanies: [ProductionCompany]
    public let productionCountries: [ProductionCountry]
    public let spokenLanguages: [SpokenLanguage]

    public init(
        tmdbId: Int,
        title: String,
        overview: String?,
        backdropPath: String?,
        posterPath: String?,
        voteAverage: Double,
        releaseDate: String?,
        runtime: Int?,
        tagline: String?,
        budget: Int,
        revenue: Int,
        genres: [Genre],
        productionCompanies: [ProductionCompany],
        productionCountries: [ProductionCountry],
        spokenLanguages: [SpokenLanguage]
    ) {
        self.tmdbId = tmdbId
        self.title = title
        self.overview = overview
        self.backdropPath = backdropPath
        self.posterPath = posterPath
        self.voteAverage = voteAverage
        self.releaseDate = releaseDate
        self.runtime = runtime
        self.tagline = tagline
        self.budget = budget
        self.revenue = revenue
        self.genres = genres
        self.productionCompanies = productionCompanies
        self.productionCountries = productionCountries
        self.spokenLanguages = spokenLanguages
    }

    enum CodingKeys: String, CodingKey {
        case title, overview, tagline, budget, revenue, genres, runtime
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case backdropPath = "backdrop_path"
        case posterPath = "poster_path"
        case tmdbId = "id"
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case spokenLanguages = "spoken_languages"
    }
}

// MARK: - Supporting Models

public nonisolated struct Genre: Codable, Sendable, Identifiable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

public nonisolated struct ProductionCompany: Codable, Sendable, Identifiable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

public nonisolated struct ProductionCountry: Codable, Sendable, Identifiable {
    public let iso3166_1: String
    public let name: String

    public var id: String { iso3166_1 }

    public init(iso3166_1: String, name: String) {
        self.iso3166_1 = iso3166_1
        self.name = name
    }

    enum CodingKeys: String, CodingKey {
        case iso3166_1 = "iso_3166_1"
        case name
    }
}

public nonisolated struct SpokenLanguage: Codable, Sendable, Identifiable {
    public let iso639_1: String
    public let name: String
    public let englishName: String?

    public var id: String { iso639_1 }

    public init(iso639_1: String, name: String, englishName: String?) {
        self.iso639_1 = iso639_1
        self.name = name
        self.englishName = englishName
    }

    enum CodingKeys: String, CodingKey {
        case iso639_1 = "iso_639_1"
        case name
        case englishName = "english_name"
    }
}
