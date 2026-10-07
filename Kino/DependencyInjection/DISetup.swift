//
//  DISetup.swift
//  Kino
//
//  Created by Marco Maddalena on 23.03.26.
//

import AppFeatures
import Foundation
import Networking
import SwiftData

func setupDependencies() {
    do {
        let config = try NetworkConfig()
        DIContainer.shared.register(config)

        let networkClient = NetworkClient()
        DIContainer.shared.register(networkClient as NetworkClientProtocol)

        let kinoAPIConfig = KinoAPIConfig()
        DIContainer.shared.register(kinoAPIConfig)
        
        let movieService = MovieService()
        DIContainer.shared.register(movieService as MovieServiceProtocol)
        
        let searchService = SearchService()
        DIContainer.shared.register(searchService as SearchServiceProtocol)
        
        let imageCache = ImageCache()
        DIContainer.shared.register(imageCache as ImageCaching)

        let imageService = ImageService(
            networkClient: networkClient,
            imageBaseURL: config.imageBaseURL,
            cache: imageCache
        )
        DIContainer.shared.register(imageService as ImageServiceProtocol)

        let modelContainer = try PersistenceFactory.createModelContainer()
        let modelContext = ModelContext(modelContainer)

        DIContainer.shared.register(modelContainer)
        
        let movieListCache = MovieListCache(modelContext: modelContext)
        DIContainer.shared.register(movieListCache)
        
        let movieRepository = MovieRepository()
        DIContainer.shared.register(movieRepository as MovieRepositoryProtocol)
        
        let recentlyViewedCache = RecentlyViewedCache(modelContext: modelContext)
        DIContainer.shared.register(recentlyViewedCache)
        
        let recentlyViewedRepository = RecentlyViewedRepository()
        DIContainer.shared.register(recentlyViewedRepository as RecentlyViewedRepositoryProtocol)

        let keychainService = KeychainService()
        DIContainer.shared.register(keychainService as KeychainServiceProtocol)

        let sessionManager = SessionManager()
        DIContainer.shared.register(sessionManager as SessionManagerProtocol)

        let authService = AuthService()
        DIContainer.shared.register(authService as AuthServiceProtocol)

        let listsService = ListsService()
        DIContainer.shared.register(listsService as ListsServiceProtocol)
    } catch {
        print("❌ Failed to setup dependencies: \(error)")
    }
}
