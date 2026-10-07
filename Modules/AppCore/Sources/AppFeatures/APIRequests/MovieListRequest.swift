//
//  MovieListRequest.swift
//  Kino
//
//  Created by Marco Maddalena on 22.03.26.
//

import AppFeatures
import Foundation
import Models
import Networking

public struct MovieListRequest: NetworkRequest, Sendable {
    public typealias Response = MovieListResponse
    
    public let baseURL: URL
    public let endpoint: String = "discover/movie"
    public let method: HTTPMethod = .get
    public let headers: [String: String]
    public let queryParameters: [String: String]?

    public init(baseURL: URL, accessToken: String, page: Int = 1) {
        self.baseURL = baseURL
        self.headers = ["Accept": "application/json", "Authorization": "Bearer \(accessToken)"]
        self.queryParameters = [
            "page": String(page),
            "include_adult": "false",
            "language": "en-US",
            "sort_by": "primary_release_date.desc",
            "primary_release_date.lte": Date.todayAsAPIFormat()
        ]
    }
}
