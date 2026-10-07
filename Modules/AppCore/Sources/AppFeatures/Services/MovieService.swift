//
//  MovieService.swift
//  Kino
//
//  Created by Marco Maddalena on 23.03.26.
//

import Foundation
import Models
import Networking
import os

public protocol MovieServiceProtocol {
    func fetchMovies(page: Int) async throws -> MovieListResponse
    func fetchMovieDetail(id: Int) async throws -> MovieDetail
}

public class MovieService: MovieServiceProtocol {
    @Injected<NetworkClientProtocol> var networkClient: any NetworkClientProtocol
    @Injected<NetworkConfig> var networkConfig: NetworkConfig

    public init() {}

    public func fetchMovies(page: Int = 1) async throws -> MovieListResponse {
        let request = MovieListRequest(baseURL: networkConfig.baseURL, accessToken: networkConfig.accessToken, page: page)
        let response = try await networkClient.fetch(request)
        
        print("🎬 Fetched discover/movie: page \(response.page), movies: \(response.results.count), total: \(response.totalResults)")

        return response
    }
    
    public func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        let request = MovieDetailRequest(baseURL: networkConfig.baseURL, accessToken: networkConfig.accessToken, movieId: id)
        let response = try await networkClient.fetch(request)
        
        print("🎬 Fetched movie/\(id): title '\(response.title)'")

        return response
    }
}
