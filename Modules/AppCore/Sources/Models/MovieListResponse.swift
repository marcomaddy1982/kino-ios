//
//  MovieListResponse.swift
//  Kino
//
//  Created by Marco Maddalena on 23.03.26.
//

import Foundation

public nonisolated struct MovieListResponse: Codable, Sendable, Equatable {
    public let page: Int
    public let results: [Movie]
    public let totalPages: Int
    public let totalResults: Int

    public init(page: Int, results: [Movie], totalPages: Int, totalResults: Int) {
        self.page = page
        self.results = results
        self.totalPages = totalPages
        self.totalResults = totalResults
    }

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
