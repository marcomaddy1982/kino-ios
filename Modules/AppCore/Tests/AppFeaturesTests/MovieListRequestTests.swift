//
//  MovieListRequestTests.swift
//  KinoTests
//
//  Created by Marco Maddalena on 23.03.26.
//

import AppFeatures
import Foundation
import Networking
import Testing
import TestSupport


@Suite("MovieListRequest Tests")
@MainActor
struct MovieListRequestTests {
    
    let baseURL = URL(string: "https://api.example.com")!
    
    @Test("Request has correct endpoint")
    func testEndpoint() {
        let request = MovieListRequest(baseURL: baseURL, accessToken: "test-token", page: 1)
        #expect(request.endpoint == "discover/movie")
    }
    
    @Test("Request method is GET")
    func testMethod() {
        let request = MovieListRequest(baseURL: baseURL, accessToken: "test-token", page: 1)
        #expect(request.method == .get)
    }
    
    @Test("Request includes Accept header")
    func testHeaders() {
        let request = MovieListRequest(baseURL: baseURL, accessToken: "test-token", page: 1)
        #expect(request.headers["Accept"] == "application/json")
    }
    
    @Test("Query parameters include page number")
    func testPageParameter() {
        let request = MovieListRequest(baseURL: baseURL, accessToken: "test-token", page: 3)
        #expect(request.queryParameters?["page"] == "3")
    }
    
    @Test("Different pages produce different URLs")
    func testMultiplePagesProduceDifferentURLs() throws {
        let request1 = MovieListRequest(baseURL: baseURL, accessToken: "test-token", page: 1)
        let request2 = MovieListRequest(baseURL: baseURL, accessToken: "test-token", page: 2)
        
        let urlRequest1 = try request1.buildURLRequest()
        let urlRequest2 = try request2.buildURLRequest()
        
        #expect(urlRequest1.url?.absoluteString != urlRequest2.url?.absoluteString)
    }
    
    @Test("buildURLRequest constructs valid URL")
    func testBuildURLRequest() throws {
        let request = MovieListRequest(baseURL: baseURL, accessToken: "test-token", page: 1)
        let urlRequest = try request.buildURLRequest()
        
        #expect(urlRequest.httpMethod == "GET")
        #expect(urlRequest.url?.scheme == "https")
        #expect(urlRequest.url?.host == "api.example.com")
        #expect(urlRequest.url?.path == "/discover/movie")
    }
    
    @Test("buildURLRequest includes all query parameters")
    func testBuildURLRequestQueryParameters() throws {
        let request = MovieListRequest(baseURL: baseURL, accessToken: "test-token", page: 2)
        let urlRequest = try request.buildURLRequest()
        
        guard let urlString = urlRequest.url?.absoluteString else {
            Issue.record("URL is nil")
            return
        }
        
        #expect(urlString.contains("page=2"))
        #expect(urlString.contains("sort_by=primary_release_date.desc"))
        #expect(urlString.contains("primary_release_date.lte="))
    }
}
