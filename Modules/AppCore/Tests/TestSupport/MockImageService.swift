//
//  MockImageService.swift
//  KinoTests
//
//  Created by Marco Maddalena on 23.03.26.
//

import AppFeatures
import SwiftUI

public final class MockImageService: ImageServiceProtocol {
    public var shouldSucceed: Bool = true
    public var mockImage: Image?
    
    public var loadImageCallCount: Int = 0
    public var lastPosterPathRequested: String?
    
    public var buildImageURLCallCount: Int = 0
    public var lastPathRequested: String?
    public var lastSizeRequested: String?
    
    public init() {}

    public func simulateSuccess(with image: Image) {
        shouldSucceed = true
        mockImage = image
    }

    public func simulateFailure() {
        shouldSucceed = false
        mockImage = nil
    }
    
    public func loadImage(from posterPath: String) async -> Image? {
        loadImageCallCount += 1
        lastPosterPathRequested = posterPath
        
        guard shouldSucceed else {
            return nil
        }
        
        return mockImage
    }
    
    public func buildImageURL(path: String, size: String) -> URL {
        buildImageURLCallCount += 1
        lastPathRequested = path
        lastSizeRequested = size
        
        // Return a mock URL for testing
        return URL(string: "https://image.tmdb.org/t/p/\(size)\(path)")!
    }
}
