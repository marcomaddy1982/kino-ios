//
//  SearchMovieRequest.swift
//  Kino
//
//  Created by Marco Maddalena on 24.03.26.
//

import Foundation
import Models
import Networking

public struct SearchMovieRequest: NetworkRequest, Sendable {
    public typealias Response = MovieListResponse
    
    public let baseURL: URL
    public let query: String
    public let page: Int
    
    public let endpoint: String = "search/movie"
    public let method: HTTPMethod = .get
    public let headers: [String: String]
    public let queryParameters: [String: String]?

    public init(baseURL: URL, accessToken: String, query: String, page: Int = 1) {
        self.baseURL = baseURL
        self.headers = ["Accept": "application/json", "Authorization": "Bearer \(accessToken)"]
        self.query = query
        self.page = page
        self.queryParameters = [
            "query": query,
            "page": String(page),
            "include_adult": "false",
            "language": "en-US"
        ]
    }
}
