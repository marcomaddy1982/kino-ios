import AppFeatures
import AuthFeature
import SwiftUI

public struct AppRootView: View {
    @State private var viewModel = AppRootViewModelFactory.make()

    public init() {}

    public var body: some View {
        @Bindable var viewModel = viewModel
        if viewModel.isAuthenticated {
            TabView(selection: $viewModel.selectedTab) {
                DiscoverTab()
                    .tabItem { Label(LocalizedStringResource("tab.discover", bundle: #bundle), systemImage: "list.bullet") }
                    .tag(AppTab.discover)

                SearchTab()
                    .tabItem { Label(LocalizedStringResource("tab.search", bundle: #bundle), systemImage: "magnifyingglass") }
                    .tag(AppTab.search)

                RecentlyViewedTab()
                    .tabItem { Label(LocalizedStringResource("tab.recentlyViewed", bundle: #bundle), systemImage: "clock") }
                    .tag(AppTab.recentlyViewed)
            }
        } else {
            AuthContainer()
        }
    }
}

#Preview {
    AppRootView()
}
