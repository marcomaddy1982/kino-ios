import AppFeatures
import DesignSystem
import SwiftUI

public struct SettingsSheet: View {
    @State private var router = SettingsRouter()
    @State private var viewModel = SettingsViewModelFactory.makeSettingsViewModel()

    public init() {}

    public var body: some View {
        NavigationStack(path: $router.path) {
            SettingsView(viewModel: viewModel)
                .navigationDestination(for: SettingsRoute.self) { route in
                    switch route {
                    case .defaultTabPicker:
                        DefaultTabPickerView(viewModel: viewModel)
                    case .cacheDetail:
                        CacheDetailView(viewModel: viewModel)
                    }
                }
        }
        .environment(router)
    }
}

// MARK: - Default Tab Picker

struct DefaultTabPickerView: View {
    var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var viewModel = viewModel
        List {
            ForEach(DefaultTab.allCases, id: \.self) { tab in
                Button {
                    viewModel.defaultTab = tab
                    dismiss()
                } label: {
                    HStack {
                        Text(tab.label)
                            .foregroundColor(.primary)
                        Spacer()
                        if tab == viewModel.defaultTab {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppColors.primary)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
        .navigationTitle(LocalizedStringResource("settings.section.defaultTab", bundle: #bundle))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Cache Detail

struct CacheDetailView: View {
    var viewModel: SettingsViewModel

    var body: some View {
        @Bindable var viewModel = viewModel
        List {
            Section {
                HStack {
                    Text("settings.cache.itemCountLabel", bundle: .module)
                    Spacer()
                    Text(viewModel.cacheItemCount == 0
                         ? String(localized: "settings.cache.empty", bundle: .module)
                         : String(format: String(localized: "settings.cache.itemCount", bundle: .module), viewModel.cacheItemCount))
                        .foregroundColor(.secondary)
                }

                Text("settings.cache.description", bundle: .module)
                    .font(AppFonts.caption)
                    .foregroundColor(.secondary)
            }

            Section {
                Button(role: .destructive) {
                    viewModel.requestClearCache()
                } label: {
                    Label(LocalizedStringResource("settings.cache.clear", bundle: #bundle), systemImage: "trash")
                }

                if viewModel.isCacheCleared {
                    Label {
                        Text("settings.cache.cleared", bundle: .module)
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.successGreen)
                    }
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.successGreen)
                }
            }
        }
        .navigationTitle(LocalizedStringResource("settings.section.cache", bundle: #bundle))
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            LocalizedStringResource("settings.cache.confirmTitle", bundle: #bundle),
            isPresented: $viewModel.showClearCacheConfirmation
        ) {
            Button(LocalizedStringResource("settings.cache.confirmButton", bundle: #bundle), role: .destructive) {
                Task { await viewModel.clearCache() }
            }
            Button(LocalizedStringResource("common.cancel", bundle: #bundle), role: .cancel) {}
        } message: {
            Text("settings.cache.confirmMessage", bundle: .module)
        }
    }
}

#Preview {
    SettingsSheet()
}
