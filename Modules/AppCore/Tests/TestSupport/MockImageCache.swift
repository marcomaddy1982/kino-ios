//
//  MockImageCache.swift
//  KinoTests
//
//  Created by Marco Maddalena on 23.03.26.
//

import AppFeatures
import SwiftUI

public actor MockImageCache: ImageCaching {
    private var cache: [URL: Image] = [:]
    
    public nonisolated(unsafe) var getCachedImageCallCount: Int = 0
    public nonisolated(unsafe) var setCachedImageCallCount: Int = 0
    public nonisolated(unsafe) var removeAllCallCount: Int = 0
    
    public init() {}
    
    public func getCachedImage(_ url: URL) -> Image? {
        getCachedImageCallCount += 1
        return cache[url]
    }
    
    public func setCachedImage(_ image: Image, for url: URL) {
        setCachedImageCallCount += 1
        cache[url] = image
    }
    
    public func removeAll() {
        removeAllCallCount += 1
        cache.removeAll()
    }

    public func count() -> Int {
        cache.count
    }

    public func prePopulate(with images: [URL: Image]) {
        for (url, image) in images {
            cache[url] = image
        }
    }
}
