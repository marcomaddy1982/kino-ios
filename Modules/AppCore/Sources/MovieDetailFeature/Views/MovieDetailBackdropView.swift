//
//  MovieDetailBackdropView.swift
//  Kino
//
//  Created by Marco Maddalena on 24.03.26.
//

import AppFeatures
import DesignSystem
import SwiftUI

struct MovieDetailBackdropView: View {
    let backdropPath: String?
    let imageService: ImageServiceProtocol
    
    var body: some View {
        if let backdropPath {
            ZStack {
                CacheAsyncImage(
                    imageService: imageService,
                    posterPath: backdropPath
                ) { phase in
                    switch phase {
                    case .empty:
                        VStack {
                            ProgressView()
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(AppColors.backgroundNeutral)
                        
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                        
                    case .failure:
                        PlaceholderImageView(size: .large, imageName: "film.fill")
                        
                    @unknown default:
                        EmptyView()
                    }
                }
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
}
