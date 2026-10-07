//
//  SearchResultsGridView.swift
//  Kino
//
//  Created by Marco Maddalena on 25.03.26.
//

import AppFeatures
import Models
import MovieListFeature
import Networking
import SwiftUI

struct SearchResultsGridView: View {
    let searchResults: [Movie]
    let shouldLoadNextPage: (Movie) -> Bool
    let onNextPageLoad: () -> Void
    let imageService: any ImageServiceProtocol

    @Environment(TabRouter.self) private var router
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var gridSpacing: CGFloat = 16
    @ScaledMetric(relativeTo: .body) private var gridPadding: CGFloat = 16

    private var columns: [GridItem] {
        dynamicTypeSize >= .accessibility1
            ? [GridItem(.flexible())]
            : [GridItem(.flexible()), GridItem(.flexible())]
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(spacing: gridSpacing) {
                    LazyVGrid(
                        columns: columns,
                        spacing: gridSpacing
                    ) {
                        ForEach(searchResults, id: \.id) { movie in
                            MovieCardView(viewModel: MovieCardViewModel(movie: movie, imageService: imageService), onTap: { router.navigate(to: .movieDetail($0)) })
                                .onAppear {
                                    if shouldLoadNextPage(movie) {
                                        onNextPageLoad()
                                    }
                                }
                        }
                    }
                }
                .padding(gridPadding)
            }
        }
    }
}

#Preview {
    if let config = try? NetworkConfig() {
        let networkClient = NetworkClient()
        let imageService = ImageService(networkClient: networkClient, imageBaseURL: config.imageBaseURL, cache: ImageCache())

        NavigationStack {
            SearchResultsGridView(
                searchResults: [
                    Movie(
                        tmdbId: 550,
                        title: "Fight Club",
                        posterPath: "/a26cQPRhJPX6GbWfQbvZdrrVzqa.jpg",
                        voteAverage: 8.4,
                        overview: "A ticking-time-bomb incarcerates a man in an everchanging prison cell.",
                        releaseDate: "1999-10-15"
                    ),
                    Movie(
                        tmdbId: 278,
                        title: "The Shawshank Redemption",
                        posterPath: "/q6725aR8Zs4IwGMAneuEYkAQCgd.jpg",
                        voteAverage: 9.3,
                        overview: "Two imprisoned men bond over a number of years.",
                        releaseDate: "1994-10-14"
                    )
                ],
                shouldLoadNextPage: { _ in false },
                onNextPageLoad: { print("Loading next page") },
                imageService: imageService
            )
        }
        .environment(TabRouter())
    } else {
        Text("Preview error")
    }
}
