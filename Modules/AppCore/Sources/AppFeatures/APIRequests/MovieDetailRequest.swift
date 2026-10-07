//
//  MovieDetailRequest.swift
//  Kino
//
//  Created by Marco Maddalena on 24.03.26.
//

import Foundation
import Models
import Networking

public struct MovieDetailRequest: NetworkRequest, Sendable {
    public typealias Response = MovieDetail
    
    public let baseURL: URL
    public let endpoint: String
    public let method: HTTPMethod = .get
    public let headers: [String: String]
    public let queryParameters: [String: String]? = nil

    public init(baseURL: URL, accessToken: String, movieId: Int) {
        self.baseURL = baseURL
        self.headers = ["Accept": "application/json", "Authorization": "Bearer \(accessToken)"]
        self.endpoint = "movie/\(movieId)"
    }
}
