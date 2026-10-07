//
//  MockMovieService.swift
//  KinoTests
//
//  Created by Marco Maddalena on 23.03.26.
//

import AppFeatures
import Foundation
import Models
import Networking

public final class MockMovieService: MovieServiceProtocol {
    public var shouldSucceed: Bool = true
    public var mockResponse: MovieListResponse?
    public var error: Error?
    
    public var fetchMoviesCallCount: Int = 0
    public var lastPageRequested: Int?
    
    public var detailShouldSucceed: Bool = true
    public var detailMockResponse: MovieDetail?
    public var detailError: Error?
    
    public var fetchMovieDetailCallCount: Int = 0
    public var lastMovieIdRequested: Int?
    
    public init() {}

    public func simulateSuccess(with response: MovieListResponse) {
        shouldSucceed = true
        mockResponse = response
        error = nil
    }

    public func simulateFailure(with error: Error) {
        shouldSucceed = false
        mockResponse = nil
        self.error = error
    }
    
    public func simulateDetailSuccess(with response: MovieDetail) {
        detailShouldSucceed = true
        detailMockResponse = response
        detailError = nil
    }
    
    public func simulateDetailFailure(with error: Error) {
        detailShouldSucceed = false
        detailMockResponse = nil
        detailError = error
    }
    
    public func fetchMovies(page: Int = 1) async throws -> MovieListResponse {
        fetchMoviesCallCount += 1
        lastPageRequested = page
        
        if !shouldSucceed, let error = error {
            throw error
        }
        
        guard let response = mockResponse else {
            throw NetworkError.noData
        }
        
        return response
    }
    
    public func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        fetchMovieDetailCallCount += 1
        lastMovieIdRequested = id
        
        if !detailShouldSucceed, let error = detailError {
            throw error
        }
        
        guard let response = detailMockResponse else {
            throw NetworkError.noData
        }
        
        return response
    }
}
