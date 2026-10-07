//
//  ImageCache.swift
//  Kino
//
//  Created by Marco Maddalena on 23.03.26.
//

import SwiftUI

public protocol ImageCaching {
    func getCachedImage(_ url: URL) async -> Image?
    func setCachedImage(_ image: Image, for url: URL) async
    func removeAll() async
    func count() async -> Int
}

public actor ImageCache: ImageCaching {
    private var cache: [URL: Image] = [:]

    public init() {}

    public func getCachedImage(_ url: URL) -> Image? {
        cache[url]
    }

    public func setCachedImage(_ image: Image, for url: URL) {
        cache[url] = image
    }

    public func removeAll() {
        cache.removeAll()
    }

    public func count() -> Int {
        cache.count
    }
}
