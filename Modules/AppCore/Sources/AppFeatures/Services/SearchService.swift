//
//  SearchService.swift
//  Kino
//
//  Created by Marco Maddalena on 24.03.26.
//

import Foundation
import Models
import Networking
import os

public protocol SearchServiceProtocol {
    func searchMovies(query: String, page: Int) async throws -> MovieListResponse
}

public class SearchService: SearchServiceProtocol {
    @Injected<NetworkClientProtocol> var networkClient: any NetworkClientProtocol
    @Injected<NetworkConfig> var networkConfig: NetworkConfig

    private var searchTask: Task<Void, Never>?
    private let debounceDelay: UInt64 = 300_000_000 // 300ms in nanoseconds

    public init() {}

    public func searchMovies(query: String, page: Int) async throws -> MovieListResponse {
        let request = SearchMovieRequest(
            baseURL: networkConfig.baseURL,
            accessToken: networkConfig.accessToken,
            query: query,
            page: page
        )
        let response = try await networkClient.fetch(request)
        
        print("🔍 Searched movies: query '\(query)', page \(response.page), results: \(response.results.count), total: \(response.totalResults)")

        return response
    }
    
    func debouncedSearch(query: String, page: Int) async throws -> MovieListResponse {
        // Cancel previous search task if it exists
        searchTask?.cancel()
        
        // Wait for debounce delay
        try await Task.sleep(nanoseconds: debounceDelay)
        
        // Check if task was cancelled during sleep
        if Task.isCancelled {
            throw NetworkError.unknown(NSError(domain: "SearchService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Search was cancelled"]))
        }
        
        return try await searchMovies(query: query, page: page)
    }
}
