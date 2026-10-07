//
//  MovieDetailSuccessView.swift
//  Kino
//
//  Created by Marco Maddalena on 27.03.26.
//

import Models
import SwiftUI

struct MovieDetailSuccessView: View {
    let viewModel: MovieDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Backdrop Image
                MovieDetailBackdropView(
                    backdropPath: viewModel.backdropPath,
                    imageService: viewModel.imageService
                )
                
                VStack(alignment: .leading, spacing: 16) {
                    // Header with title, vote average, and tagline
                    MovieDetailHeaderView(
                        title: viewModel.title,
                        voteAverage: viewModel.voteAverageFormatted,
                        tagline: viewModel.tagline,
                        hasTagline: viewModel.hasTagline
                    )
                    
                    Divider()
                    
                    // Metadata (release date, runtime)
                    MovieDetailMetadataView(
                        releaseDate: viewModel.releaseDate,
                        runtime: viewModel.runtime
                    )
                    
                    Divider()
                    
                    // Overview
                    MovieDetailOverviewView(overview: viewModel.overview)
                    
                    // Attributes (genres, production companies, countries, languages)
                    MovieDetailAttributesView(
                        hasGenres: viewModel.hasGenres,
                        genres: viewModel.genres,
                        hasProductionCompanies: viewModel.hasProductionCompanies,
                        productionCompanies: viewModel.productionCompanies,
                        hasProductionCountries: viewModel.hasProductionCountries,
                        productionCountries: viewModel.productionCountries,
                        hasSpokenLanguages: viewModel.hasSpokenLanguages,
                        spokenLanguages: viewModel.spokenLanguages
                    )
                    
                    // Financial info (budget, revenue)
                    if viewModel.hasFinancialInfo {
                        MovieDetailFinancialView(
                            budget: viewModel.budget,
                            revenue: viewModel.revenue
                        )
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    let movie = Movie(
        tmdbId: 278,
        title: "The Shawshank Redemption",
        posterPath: "/test.jpg",
        voteAverage: 9.3,
        overview: "Two imprisoned men bond over a number of years.",
        releaseDate: "1994-09-23"
    )
    
    MovieDetailSuccessView(
        viewModel: MovieDetailViewModelFactory.makeMovieDetailViewModel(for: movie)
    )
}
