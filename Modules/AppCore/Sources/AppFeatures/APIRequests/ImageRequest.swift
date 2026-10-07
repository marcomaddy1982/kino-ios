//
//  ImageRequest.swift
//  Kino
//
//  Created by Marco Maddalena on 23.03.26.
//

import Foundation
import Networking

public struct ImageRequest: NetworkRequest, Sendable {
    public typealias Response = Data
    
    public let baseURL: URL
    public let endpoint: String
    public let method: HTTPMethod = .get
    public let headers: [String: String] = [:]
    public let queryParameters: [String: String]? = nil
    
    public init(baseURL: URL, endpoint: String) {
        self.baseURL = baseURL
        self.endpoint = endpoint
    }
}
