import AppFeatures
import DesignSystem
import SwiftUI

struct SettingsView: View {
    var viewModel: SettingsViewModel
    @State private var authViewModel = AuthViewModelFactory.makeAuthViewModel()
    @Environment(SettingsRouter.self) private var router
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var viewModel = viewModel
        Form {
            accountSection
            preferencesSection
            cacheSection
            aboutSection
        }
        .preferredColorScheme(viewModel.appearanceMode.colorScheme)
        .navigationTitle(LocalizedStringResource("settings.navigationTitle", bundle: #bundle))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .onAppear { viewModel.refreshDefaultTab() }
        .task { await viewModel.loadCacheCount() }
    }

    // MARK: - Sections

    private var accountSection: some View {
        Section(LocalizedStringResource("settings.section.account", bundle: #bundle)) {
            switch authViewModel.state {
            case .loggedOut:
                Text("settings.account.loggedOut")
                    .foregroundColor(.secondary)
                    .font(AppFonts.caption)

            case .loading:
                HStack {
                    ProgressView()
                    Text("settings.account.loading", bundle: .module)
                        .foregroundColor(.secondary)
                        .font(AppFonts.caption)
                }

            case .loggedIn:
                accountProfileCard()
                Button(LocalizedStringResource("settings.account.logout", bundle: #bundle), role: .destructive) {
                    Task { await authViewModel.logout() }
                }

            case .error(let message):
                Label {
                    Text(message)
                } icon: {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                }
                .font(AppFonts.caption)
            }
        }
    }

    private func accountProfileCard() -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)

                Image(systemName: "person.fill")
                    .font(AppFonts.label)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("settings.account.session", bundle: .module)
                    .font(AppFonts.label)
                    .foregroundColor(.primary)

                HStack(spacing: 4) {
                    Circle()
                        .fill(AppColors.successGreen)
                        .frame(width: 7, height: 7)
                    Text("settings.account.sessionActive", bundle: .module)
                        .font(AppFonts.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var preferencesSection: some View {
        @Bindable var viewModel = viewModel
        return Section(LocalizedStringResource("settings.section.preferences", bundle: #bundle)) {
            HStack(spacing: 12) {
                iconBadge(systemName: "circle.lefthalf.filled", color: .purple)
                Picker(LocalizedStringResource("settings.section.appearance", bundle: #bundle), selection: $viewModel.appearanceMode) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Button {
                router.navigate(to: .defaultTabPicker)
            } label: {
                HStack(spacing: 12) {
                    iconBadge(systemName: "star.fill", color: AppColors.primary)
                    Text("settings.section.defaultTab", bundle: .module)
                    Spacer()
                    Text(viewModel.currentDefaultTab.label)
                        .foregroundColor(.secondary)
                        .font(AppFonts.body)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .foregroundColor(.primary)
            }
        }
    }

    private var cacheSection: some View {
        Button {
            router.navigate(to: .cacheDetail)
        } label: {
            HStack(spacing: 12) {
                iconBadge(systemName: "internaldrive", color: .orange)
                Text("settings.section.cache", bundle: .module)
                Spacer()
                Text(viewModel.cacheItemCount == 0
                     ? String(localized: "settings.cache.empty", bundle: .module)
                     : String(format: String(localized: "settings.cache.itemCount", bundle: .module), viewModel.cacheItemCount))
                    .foregroundColor(.secondary)
                    .font(AppFonts.caption)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .foregroundColor(.primary)
        }
    }

    private var aboutSection: some View {
        Section(LocalizedStringResource("settings.section.about", bundle: #bundle)) {
            HStack(spacing: 12) {
                iconBadge(systemName: "info.circle.fill", color: Color(.systemGray))
                LabeledContent {
                    Text(viewModel.appVersion)
                        .foregroundColor(.secondary)
                } label: {
                    Text("settings.about.version", bundle: .module)
                }
            }

            HStack(spacing: 12) {
                iconBadge(systemName: "film.fill", color: AppColors.successGreen)
                LabeledContent {
                    Text("TMDB")
                        .foregroundColor(.secondary)
                } label: {
                    Text("settings.about.dataSource", bundle: .module)
                }
            }
        }
    }

    // MARK: - Helpers

    private func iconBadge(systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 28, height: 28)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
    }
}

#Preview {
    SettingsSheet()
}
