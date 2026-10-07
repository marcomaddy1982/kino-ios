import AppFeatures
import DesignSystem
import Models
import SwiftUI

@MainActor
struct ListsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ListsRouter.self) private var router
    @State private var viewModel = ListsViewModelFactory.makeListsViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .success(let lists):
                List {
                    ForEach(lists) { list in
                        HStack {
                            Text(list.name)
                            Spacer()
                            Text("\(list.itemCount)")
                                .foregroundStyle(.secondary)
                            if list.isFavourite {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.red)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            router.navigate(to: .listDetail(list))
                        }
                        .swipeActions(edge: .trailing) {
                            if !list.isFavourite {
                                Button(role: .destructive) {
                                    Task { await viewModel.deleteList(id: list.id) }
                                } label: {
                                    Label("common.delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            case .error(let message):
                ErrorStateView(
                    errorMessage: message,
                    onRetry: { await viewModel.loadLists() }
                )
            }
        }
        .navigationTitle(LocalizedStringResource("lists.navigationTitle", bundle: #bundle))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .task {
            await viewModel.loadLists()
        }
    }
}

#Preview {
    ListsSheet()
}
