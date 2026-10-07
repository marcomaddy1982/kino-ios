//
//  TestDataBuilder.swift
//  KinoTests
//
//  Created by Marco Maddalena on 23.03.26.
//

import Foundation
import Models
import Networking

public struct TestDataBuilder {

    public static func makeSampleMovie(
        id: UUID = UUID(),
        tmdbId: Int = 278,
        title: String = "Test Movie",
        posterPath: String? = "/test-poster.jpg",
        voteAverage: Double = 7.5,
        overview: String? = "A test movie overview",
        releaseDate: String? = "2024-01-01"
    ) -> Movie {
        Movie(
            id: id,
            tmdbId: tmdbId,
            title: title,
            posterPath: posterPath,
            voteAverage: voteAverage,
            overview: overview,
            releaseDate: releaseDate
        )
    }

    public static func makeSampleMovieList(
        count: Int = 5,
        baseTitle: String = "Movie"
    ) -> [Movie] {
        (1...count).map { index in
            makeSampleMovie(
                title: "\(baseTitle) \(index)",
                releaseDate: "2024-01-\(String(format: "%02d", index))"
            )
        }
    }

    public static func makeSampleMovieListResponse(
        page: Int = 1,
        totalPages: Int = 10,
        results: [Movie]? = nil
    ) -> MovieListResponse {
        let movies = results ?? makeSampleMovieList(count: 5)
        return MovieListResponse(
            page: page,
            results: movies,
            totalPages: totalPages,
            totalResults: totalPages * 20
        )
    }
    
    // Backward compatibility alias
    public static func makeSampleDiscoverResponse(
        page: Int = 1,
        totalPages: Int = 10,
        results: [Movie]? = nil
    ) -> MovieListResponse {
        makeSampleMovieListResponse(page: page, totalPages: totalPages, results: results)
    }
    
    public static func makeSampleNetworkError() -> NetworkError {
        NetworkError.unknown(NSError(domain: "test", code: -1, userInfo: nil))
    }
    
    // MARK: - MovieDetail Test Data
    
    public static func makeSampleGenre(id: Int = 1, name: String = "Drama") -> Genre {
        Genre(id: id, name: name)
    }
    
    public static func makeSampleGenres(count: Int = 3) -> [Genre] {
        (1...count).map { index in
            makeSampleGenre(id: index, name: "Genre \(index)")
        }
    }
    
    public static func makeSampleProductionCompany(id: Int = 1, name: String = "Test Studio") -> ProductionCompany {
        ProductionCompany(id: id, name: name)
    }
    
    public static func makeSampleProductionCompanies(count: Int = 2) -> [ProductionCompany] {
        (1...count).map { index in
            makeSampleProductionCompany(id: index, name: "Studio \(index)")
        }
    }
    
    public static func makeSampleProductionCountry(iso3166_1: String = "US", name: String = "United States") -> ProductionCountry {
        ProductionCountry(iso3166_1: iso3166_1, name: name)
    }
    
    public static func makeSampleProductionCountries(count: Int = 2) -> [ProductionCountry] {
        let countries = [
            ("US", "United States"),
            ("GB", "United Kingdom"),
            ("CA", "Canada")
        ]
        return (0..<count).map { index in
            let (iso, name) = countries[index % countries.count]
            return makeSampleProductionCountry(iso3166_1: iso, name: name)
        }
    }
    
    public static func makeSampleSpokenLanguage(
        iso639_1: String = "en",
        name: String = "English",
        englishName: String? = "English"
    ) -> SpokenLanguage {
        SpokenLanguage(iso639_1: iso639_1, name: name, englishName: englishName)
    }
    
    public static func makeSampleSpokenLanguages(count: Int = 2) -> [SpokenLanguage] {
        let languages = [
            ("en", "English", "English"),
            ("es", "Spanish", "Spanish"),
            ("fr", "French", "French")
        ]
        return (0..<count).map { index in
            let (iso, name, englishName) = languages[index % languages.count]
            return makeSampleSpokenLanguage(iso639_1: iso, name: name, englishName: englishName)
        }
    }
    
    public static func makeSampleMovieDetail(
        tmdbId: Int = 278,
        title: String = "Test Movie Detail",
        overview: String? = "A detailed overview of the test movie",
        backdropPath: String? = "/test-backdrop.jpg",
        posterPath: String? = "/test-poster.jpg",
        voteAverage: Double = 8.5,
        releaseDate: String? = "2024-01-15",
        runtime: Int? = 142,
        tagline: String? = "The test tagline",
        budget: Int = 1000000,
        revenue: Int = 5000000,
        genres: [Genre]? = nil,
        productionCompanies: [ProductionCompany]? = nil,
        productionCountries: [ProductionCountry]? = nil,
        spokenLanguages: [SpokenLanguage]? = nil
    ) -> MovieDetail {
        MovieDetail(
            tmdbId: tmdbId,
            title: title,
            overview: overview,
            backdropPath: backdropPath,
            posterPath: posterPath,
            voteAverage: voteAverage,
            releaseDate: releaseDate,
            runtime: runtime,
            tagline: tagline,
            budget: budget,
            revenue: revenue,
            genres: genres ?? makeSampleGenres(count: 2),
            productionCompanies: productionCompanies ?? makeSampleProductionCompanies(count: 1),
            productionCountries: productionCountries ?? makeSampleProductionCountries(count: 1),
            spokenLanguages: spokenLanguages ?? makeSampleSpokenLanguages(count: 1)
        )
    }
}
