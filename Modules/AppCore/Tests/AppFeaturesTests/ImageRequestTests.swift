//
//  ImageRequestTests.swift
//  KinoTests
//
//  Created by Marco Maddalena on 23.03.26.
//

import AppFeatures
import Foundation
import Networking
import Testing
import TestSupport


@Suite("ImageRequest Tests")
@MainActor
struct ImageRequestTests {
    
    let baseURL = URL(string: "https://movie.example.com/images/")!
    let endpoint = "w342/poster.jpg"
    
    @Test("Constructs correct baseURL and endpoint")
    func testBaseURLAndEndpoint() {
        let request = ImageRequest(baseURL: baseURL, endpoint: endpoint)
        
        #expect(request.baseURL.absoluteString == "https://movie.example.com/images/")
        #expect(request.endpoint == "w342/poster.jpg")
    }
    
    @Test("HTTP method is GET")
    func testMethod() {
        let request = ImageRequest(baseURL: baseURL, endpoint: endpoint)
        
        #expect(request.method == .get)
    }
    
    @Test("Query parameters are nil")
    func testQueryParameters() {
        let request = ImageRequest(baseURL: baseURL, endpoint: endpoint)
        
        #expect(request.queryParameters == nil)
    }
    
    @Test("Headers are empty")
    func testHeaders() {
        let request = ImageRequest(baseURL: baseURL, endpoint: endpoint)
        
        #expect(request.headers.isEmpty)
    }
    
    @Test("buildURLRequest constructs valid URL")
    func testBuildURLRequest() throws {
        let request = ImageRequest(baseURL: baseURL, endpoint: endpoint)
        let urlRequest = try request.buildURLRequest()
        
        #expect(urlRequest.httpMethod == "GET")
        #expect(urlRequest.url?.absoluteString == "https://movie.example.com/images/w342/poster.jpg")
    }
    
    @Test("Preserves URL scheme and host")
    func testURLSchemeAndHost() throws {
        let request = ImageRequest(baseURL: baseURL, endpoint: endpoint)
        let urlRequest = try request.buildURLRequest()
        
        #expect(urlRequest.url?.scheme == "https")
        #expect(urlRequest.url?.host == "movie.example.com")
    }
}
