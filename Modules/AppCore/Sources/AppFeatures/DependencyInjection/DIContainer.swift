//
//  DIContainer.swift
//  Kino
//
//  Created by Marco Maddalena on 23.03.26.
//

import Foundation

public nonisolated final class DIContainer: @unchecked Sendable {
    public static let shared = DIContainer()

    private var dependencies: [String: Any] = [:]

    private init() {}

    public func register<T>(_ instance: T, as type: T.Type = T.self) {
        let key = String(describing: type)
        dependencies[key] = instance
    }

    public func resolve<T>(_ type: T.Type = T.self) -> T? {
        let key = String(describing: type)
        return dependencies[key] as? T
    }

    /// Crashes if dependency not registered - use only for required dependencies
    public func requireResolve<T>(_ type: T.Type = T.self) -> T {
        guard let instance = resolve(type) else {
            fatalError("Dependency not registered: \(type). Call setupDependencies() at app startup.")
        }
        return instance
    }

    public func reset() {
        dependencies.removeAll()
    }
}
