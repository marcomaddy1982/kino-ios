//
//  TestModelContainer.swift
//  KinoTests
//
//  Created by Marco Maddalena on 25.03.26.
//

import AppFeatures
import Foundation
import SwiftData

public struct TestModelContainer {
    public static func create() throws -> ModelContainer {
        let container = try ModelContainer(
            for: MovieEntity.self, MoviePageMetadata.self, RecentlyViewedMovie.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return container
    }
    
    public static func createContext() throws -> ModelContext {
        let container = try create()
        return ModelContext(container)
    }
}
