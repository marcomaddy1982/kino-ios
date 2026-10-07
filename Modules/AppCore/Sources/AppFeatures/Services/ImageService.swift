//
//  ImageService.swift
//  Kino
//
//  Created by Marco Maddalena on 23.03.26.
//

import Networking
import SwiftUI

public protocol ImageServiceProtocol {
    func loadImage(from posterPath: String) async -> Image?
    func buildImageURL(path: String, size: String) -> URL
}

public final class ImageService: ImageServiceProtocol, Sendable {
    private let networkClient: NetworkClient
    private let imageBaseURL: URL
    private let cache: any ImageCaching

    public init(networkClient: NetworkClient, imageBaseURL: URL, cache: any ImageCaching) {
        self.networkClient = networkClient
        self.imageBaseURL = imageBaseURL
        self.cache = cache
    }

    public func loadImage(from posterPath: String) async -> Image? {
        let endpoint = buildImageEndpoint(size: "w342", path: posterPath)
        let cacheKey = buildImageURL(path: posterPath, size: "w342")

        if let cached = await cache.getCachedImage(cacheKey) {
            return cached
        }

        guard let imageData = await fetchImageData(baseURL: imageBaseURL, endpoint: endpoint),
              let uiImage = UIImage(data: imageData) else {
            return nil
        }

        let image = Image(uiImage: uiImage)
        await cache.setCachedImage(image, for: cacheKey)
        return image
    }

    public func buildImageURL(path: String, size: String) -> URL {
        return imageBaseURL.appendingPathComponent(size).appendingPathComponent(path)
    }
    
    private func buildImageEndpoint(size: String, path: String) -> String {
        return "\(size)/\(path)"
    }
    
    private func fetchImageData(baseURL: URL, endpoint: String) async -> Data? {
        do {
            let request = ImageRequest(baseURL: baseURL, endpoint: endpoint)
            return try await networkClient.fetch(request)
        } catch {
            print("❌ Image fetch failed: \(error.localizedDescription)")
            return nil
        }
    }
}
