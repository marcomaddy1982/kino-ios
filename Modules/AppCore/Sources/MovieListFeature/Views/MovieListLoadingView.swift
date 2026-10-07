//
//  MovieListLoadingView.swift
//  NeuGelbTest
//
//  Created by Marco Maddalena on 27.03.26.
//

import DesignSystem
import SwiftUI

struct MovieListLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("movieList.loading", bundle: .module)
                .headlineStyle()
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    MovieListLoadingView()
}
