import AppFeatures
import Models
import MovieListFeature
import SwiftUI

struct ListDetailView: View {
    @State var viewModel: ListDetailViewModel
    @Environment(ListsRouter.self) private var router

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .success(let items):
                if items.isEmpty {
                    ContentUnavailableView(
                        String(localized: "listDetail.empty.title", bundle: .module),
                        systemImage: "film",
                        description: Text("listDetail.empty.subtitle", bundle: .module)
                    )
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 160), spacing: 16)],
                            spacing: 16
                        ) {
                            ForEach(items) { item in
                                MovieCardView(viewModel: MovieCardViewModelFactory.makeMovieCardViewModel(for: item), onTap: { router.navigate(to: .movieDetail($0)) })
                            }
                        }
                        .padding()
                    }
                }
            case .error(let message):
                ContentUnavailableView(message, systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle(viewModel.list.name)
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load() }
    }
}
