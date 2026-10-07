//
//  MovieListSuccessView.swift
//  Kino
//
//  Created by Marco Maddalena on 27.03.26.
//

import AppFeatures
import DesignSystem
import Models
import SwiftUI

struct MovieListSuccessView: View {
    let movies: [Movie]
    let viewModel: MovieListViewModel

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
        ScrollView {
            LazyVGrid(columns: columns, spacing: gridSpacing) {
                ForEach(movies, id: \.id) { movie in
                    MovieCardView(viewModel: viewModel.makeCardViewModel(for: movie), onTap: { router.navigate(to: .movieDetail($0)) })
                        .onAppear {
                            if viewModel.shouldLoadNextPage(for: movie) {
                                Task {
                                    await viewModel.loadNextPage()
                                }
                            }
                        }
                }

                if viewModel.isPaginationLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("movieList.loadingMore", bundle: .module)
                            .captionStyle()
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .gridCellUnsizedAxes([.horizontal])
                    .padding()
                }
            }
            .padding(gridPadding)
        }
    }
}

#Preview {
    MovieListSuccessView(
        movies: [],
        viewModel: MovieListViewModelFactory.makeMovieListViewModel()
    )
}
