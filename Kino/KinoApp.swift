//
//  KinoApp.swift
//  Kino
//
//  Created by Marco Maddalena on 23.03.26.
//

import RootFeature
import SettingsFeature
import SwiftUI

@main
struct KinoApp: App {
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system

    init() {
        // Initialize dependency injection container with all required services
        setupDependencies()
    }

    var body: some Scene {
         WindowGroup {
             if !isRunningTests() {
                 AppRootView()
                     .preferredColorScheme(appearanceMode.colorScheme)
             } else {
                 EmptyView()
             }
         }
    }
}

private func isRunningTests() -> Bool {
    NSClassFromString("XCTestCase") != nil
}
