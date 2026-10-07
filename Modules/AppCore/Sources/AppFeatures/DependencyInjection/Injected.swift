//
//  Injected.swift
//  Kino
//
//  Created by Marco Maddalena on 23.03.26.
//

import Foundation

/// Property wrapper for type-safe dependency injection in Swift 6 strict mode.
@propertyWrapper
public struct Injected<T> {
    nonisolated(unsafe) private let instance: T // Bypass MainActor checks for wrapped dependency

    /// Resolves dependency at initialization time without MainActor constraints.
    public nonisolated init() {
        self.instance = DIContainer.shared.requireResolve(T.self)
    }

    public var wrappedValue: T {
        instance
    }
}
