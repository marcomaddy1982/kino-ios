//
//  RecentlyViewedViewModel.swift
//  Kino
//
//  Created by Marco Maddalena on 27.03.26.
//

import AppFeatures
import Foundation
import Observation

enum RecentlyViewedViewState {
    case empty
    case success
    case error(String)
}

@Observable
final class RecentlyViewedViewModel {
    var state: RecentlyViewedViewState = .empty
    var showClearConfirmation: Bool = false

    private let recentlyViewedRepository: RecentlyViewedRepositoryProtocol

    init(recentlyViewedRepository: RecentlyViewedRepositoryProtocol) {
        self.recentlyViewedRepository = recentlyViewedRepository
    }

    func loadRecentlyViewed() async {
        do {
            let movies = try await recentlyViewedRepository.getRecentlyViewed()
            
            if movies.isEmpty {
                self.state = .empty
            } else {
                self.state = .success
            }
            print("🎬 Loaded \(movies.count) recently viewed movies")
        } catch {
            let errorMessage = "Failed to load recently viewed movies: \(error.localizedDescription)"
            self.state = .error(errorMessage)
            print("❌ \(errorMessage)")
        }
    }

    func requestClearAll() {
        showClearConfirmation = true
    }

    func clearAll() async {
        do {
            try await recentlyViewedRepository.clearAll()
            state = .empty
        } catch {
            state = .error("Failed to clear recently viewed: \(error.localizedDescription)")
        }
    }
}

