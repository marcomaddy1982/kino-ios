//
//  RecentlyViewedView.swift
//  Kino
//
//  Created by Marco Maddalena on 27.03.26.
//

import AppFeatures
import DesignSystem
import SwiftData
import SwiftUI

@MainActor
public struct RecentlyViewedView: View {
    @State private var viewModel = RecentlyViewedViewModelFactory.makeRecentlyViewedViewModel()
    @Injected<ModelContainer> var modelContainer: ModelContainer

    public init() {}

    public var body: some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 0) {
            switch viewModel.state {
            case .empty:
                EmptyStateView(
                    icon: "clock.fill",
                    title: LocalizedStringResource("recentlyViewed.empty.title", bundle: #bundle),
                    message: LocalizedStringResource("recentlyViewed.empty.subtitle", bundle: #bundle)
                )
            case .success:
                RecentlyResearchedView()
            case .error(let message):
                ErrorStateView(
                    errorMessage: message,
                    onRetry: {
                        await viewModel.loadRecentlyViewed()
                    }
                )
            }
        }
        .navigationTitle(LocalizedStringResource("recentlyViewed.navigationTitle", bundle: #bundle))
        .modelContext(ModelContext(modelContainer))
        .toolbar {
            if case .success = viewModel.state {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringResource("recentlyViewed.clearHistory", bundle: #bundle)) {
                        viewModel.requestClearAll()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .alert(
            LocalizedStringResource("recentlyViewed.clearHistory.confirmTitle", bundle: #bundle),
            isPresented: $viewModel.showClearConfirmation
        ) {
            Button(LocalizedStringResource("recentlyViewed.clearHistory.confirmButton", bundle: #bundle), role: .destructive) {
                Task { await viewModel.clearAll() }
            }
            Button(LocalizedStringResource("common.cancel", bundle: #bundle), role: .cancel) {}
        } message: {
            Text("recentlyViewed.clearHistory.confirmMessage", bundle: .module)
        }
        .task {
            await viewModel.loadRecentlyViewed()
        }
    }
}

#Preview {
    RecentlyViewedView()
}


