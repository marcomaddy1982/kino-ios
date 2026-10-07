//
//  CacheAsyncImage.swift
//  Kino
//
//  Created by Marco Maddalena on 23.03.26.
//

import AppFeatures
import SwiftUI

enum ImageError: LocalizedError {
    case failedToLoad

    var errorDescription: String? {
        "Failed to load image"
    }
}

struct CacheAsyncImage<Content>: View where Content: View {
    private let imageService: any ImageServiceProtocol
    private let posterPath: String
    private let content: (AsyncImagePhase) -> Content
    
    @State private var image: Image?
    @State private var isLoading = true
    @State private var error: Error?
    
    init(
        imageService: any ImageServiceProtocol,
        posterPath: String,
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.imageService = imageService
        self.posterPath = posterPath
        self.content = content
    }
    
    var body: some View {
        let phase: AsyncImagePhase = if let error {
            .failure(error)
        } else if let image {
            .success(image)
        } else if isLoading {
            .empty
        } else {
            .empty
        }
        
        content(phase)
            .task {
                await loadImage()
            }
            .onDisappear {
                image = nil
                isLoading = true
                error = nil
            }
    }
    
    private func loadImage() async {
        isLoading = true
        error = nil
        
        if let loadedImage = await imageService.loadImage(from: posterPath) {
            self.image = loadedImage
            self.error = nil
        } else {
            self.error = ImageError.failedToLoad
        }
        
        isLoading = false
    }
}
