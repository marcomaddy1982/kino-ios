//
//  MovieCardView.swift
//  Kino
//
//  Created by Marco Maddalena on 23.03.26.
//

import AppFeatures
import DesignSystem
import Models
import Networking
import SwiftUI

public struct MovieCardView: View {
    @State var viewModel: MovieCardViewModel
    var onTap: (Movie) -> Void

    @ScaledMetric(relativeTo: .title) private var cardHeight: CGFloat = 245
    @ScaledMetric(relativeTo: .title) private var posterHeight: CGFloat = 140

    public init(viewModel: MovieCardViewModel, onTap: @escaping (Movie) -> Void) {
        self.viewModel = viewModel
        self.onTap = onTap
    }

    public var body: some View {
        Button {
            onTap(viewModel.movie)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                posterImageSection

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.title)
                        .labelStyle()
                        .foregroundColor(AppColors.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)

                    Label(viewModel.voteAverage, systemImage: "star.fill")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.accent)

                    Text(viewModel.releaseDate)
                        .font(AppFonts.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .padding(8)

                Spacer()
            }
            .background(AppColors.backgroundLight)
            .cornerRadius(8)
            .frame(height: cardHeight)
            .clipped()
            .onAppear {
                viewModel.loadImage()
            }
            .onDisappear {
                viewModel.cancelImageLoad()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var posterImageSection: some View {
        switch viewModel.imageState {
        case .idle:
            PlaceholderImageView(size: .small, imageName: "film.fill")

        case .loading:
            VStack {
                ProgressView()
                    .tint(AppColors.primary)
            }
            .frame(height: posterHeight)
            .frame(maxWidth: .infinity)
            .background(AppColors.backgroundNeutral)

        case .success(let image):
            image
                .resizable()
                .scaledToFill()
                .frame(height: posterHeight)
                .clipped()

        case .error:
            PlaceholderImageView(size: .small, imageName: "film.fill")
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

    if let config = try? NetworkConfig() {
        let networkClient = NetworkClient()
        let imageService = ImageService(networkClient: networkClient, imageBaseURL: config.imageBaseURL, cache: ImageCache())
        let viewModel = MovieCardViewModel(movie: movie, imageService: imageService)

        NavigationStack {
            MovieCardView(viewModel: viewModel, onTap: { _ in })
                .padding()
        }
    } else {
        Text("Preview error")
    }
}
