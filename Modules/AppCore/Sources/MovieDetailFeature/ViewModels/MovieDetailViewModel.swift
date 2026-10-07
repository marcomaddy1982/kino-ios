//
//  MovieDetailViewModel.swift
//  Kino
//
//  Created by Marco Maddalena on 24.03.26.
//

import AppFeatures
import Foundation
import Models
import Observation
import os

enum MovieDetailViewState {
    case loading
    case success(MovieDetail)
    case error(String)
}

@Observable
final class MovieDetailViewModel {
    var state: MovieDetailViewState = .loading
    var isFavourite: Bool = false

    private let movieService: MovieServiceProtocol
    private(set) var imageService: ImageServiceProtocol
    private let recentlyViewedRepository: RecentlyViewedRepositoryProtocol
    private let listsService: any ListsServiceProtocol

    private let backdropImageSize = "w780"
    
    let movie: Movie
    
    init(movie: Movie,
         movieService: MovieServiceProtocol,
         imageService: ImageServiceProtocol,
         recentlyViewedRepository: RecentlyViewedRepositoryProtocol,
         listsService: any ListsServiceProtocol
    ) {
        self.movie = movie
        self.movieService = movieService
        self.imageService = imageService
        self.recentlyViewedRepository = recentlyViewedRepository
        self.listsService = listsService
    }
    
    func loadDetail() async {
        async let movieDetail: Void = loadMovieDetail()
        async let favouriteState: Void = loadFavouriteState()
        _ = await (movieDetail, favouriteState)
    }

    func loadMovieDetail() async {
        state = .loading
        
        do {
            let detail = try await movieService.fetchMovieDetail(id: movie.tmdbId)
            self.state = .success(detail)
            print("🎬 Loaded movie detail for: \(detail.title))")
        } catch {
            let errorMessage = "Failed to load movie details: \(error.localizedDescription)"
            self.state = .error(errorMessage)
            print("❌ Failed to load movie detail: \(error.localizedDescription)")
        }
    }
    
    func loadFavouriteState() async {
        isFavourite = (try? await listsService.checkFavourite(tmdbMovieId: movie.tmdbId)) ?? false
    }

    func toggleFavourite() async {
        do {
            isFavourite = try await listsService.toggleFavourite(tmdbMovieId: movie.tmdbId)
        } catch {
            print("❌ Failed to toggle favourite: \(error.localizedDescription)")
        }
    }

    func saveRecentlyViewed() async {
        do {
            try await recentlyViewedRepository.saveMovie(movie)
            print("💾 Saved movie to recently viewed: \(movie.title)")
        } catch {
            print("❌ Failed to save recently viewed movie: \(error.localizedDescription)")
        }
    }
    
    private var detail: MovieDetail? {
        if case .success(let detail) = state {
            return detail
        }
        return nil
    }
    
    var hasTagline: Bool { detail?.tagline?.isEmpty == false }
    var hasGenres: Bool { detail?.genres.isEmpty == false }
    var hasProductionCompanies: Bool { detail?.productionCompanies.isEmpty == false }
    var hasProductionCountries: Bool { detail?.productionCountries.isEmpty == false }
    var hasSpokenLanguages: Bool { detail?.spokenLanguages.isEmpty == false }
    var hasFinancialInfo: Bool { (detail?.budget ?? 0) > 0 || (detail?.revenue ?? 0) > 0 }
    var hasBackdrop: Bool { detail?.backdropPath?.isEmpty == false     }
    
    var title: String { detail?.title ?? String(localized: "common.unknown", bundle: Bundle.module) }
    
    var voteAverageFormatted: String {
        guard let avg = detail?.voteAverage else { return String(localized: "common.notAvailable", bundle: Bundle.module) }
        return String(format: "%.1f", avg)
    }
    
    var releaseDate: String {
        (detail?.releaseDate?.asFormattedReleaseDate()) ?? String(localized: "common.notAvailable", bundle: Bundle.module)
    }
    
    var runtime: String {
        detail?.runtime?.asFormattedRuntime() ?? String(localized: "common.notAvailable", bundle: Bundle.module)
    }
    
    var overview: String {
        guard let overview = detail?.overview, !overview.isEmpty else {
            return String(localized: "common.noOverview", bundle: Bundle.module)
        }
        return overview
    }
    
    var tagline: String {
        detail?.tagline ?? ""
    }
    
    var budget: String {
        (detail?.budget ?? 0).asFormattedCurrency() ?? String(localized: "common.notAvailable", bundle: Bundle.module)
    }
    
    var revenue: String {
        (detail?.revenue ?? 0).asFormattedCurrency() ?? String(localized: "common.notAvailable", bundle: Bundle.module)
    }
    
    var genres: [Genre] {
        detail?.genres ?? []
    }
    
    var productionCompanies: [ProductionCompany] {
        detail?.productionCompanies ?? []
    }
    
    var productionCountries: [ProductionCountry] {
        detail?.productionCountries ?? []
    }
    
    var spokenLanguages: [SpokenLanguage] {
        detail?.spokenLanguages ?? []
    }
    
    var backdropPath: String? {
        detail?.backdropPath
    }
    
    var backdropImageURL: URL? {
        guard let backdropPath = detail?.backdropPath else { return nil }
        return imageService.buildImageURL(path: backdropPath, size: backdropImageSize)
    }
}
