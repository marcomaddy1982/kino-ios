//
//  MovieDetailView.swift
//  NeuGelbTest
//
//  Created by Marco Maddalena on 24.03.26.
//

import DesignSystem
import Models
import SwiftUI

public struct MovieDetailView: View {
    @State private var viewModel: MovieDetailViewModel

    public init(movie: Movie) {
        _viewModel = State(wrappedValue: MovieDetailViewModelFactory.makeMovieDetailViewModel(for: movie))
    }

    public var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                MovieDetailLoadingView()
                
            case .success:
                MovieDetailSuccessView(viewModel: viewModel)
                
            case .error(let errorMessage):
                ErrorStateView(errorMessage: errorMessage, onRetry: {
                    await viewModel.loadMovieDetail()
                })
            }
        }
        .navigationTitle(LocalizedStringResource("movieDetail.navigationTitle", bundle: #bundle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task { await viewModel.toggleFavourite() }
                } label: {
                    Image(systemName: viewModel.isFavourite ? "heart.fill" : "heart")
                        .foregroundStyle(.red)
                }
            }
        }
        .task {
            await viewModel.loadDetail()
        }
        .onAppear {
            Task {
                await viewModel.saveRecentlyViewed()
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
    
    NavigationStack {
        MovieDetailView(movie: movie)
    }
}
