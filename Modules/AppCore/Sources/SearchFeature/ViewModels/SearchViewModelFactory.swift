//
//  SearchViewModelFactory.swift
//  Kino
//
//  Created by Marco Maddalena on 25.03.26.
//

import AppFeatures
import Foundation

@MainActor
final class SearchViewModelFactory {
    @Injected<SearchServiceProtocol> var searchService
    @Injected<ImageServiceProtocol> var imageService
    
    static func makeSearchViewModel() -> SearchViewModel {
        let factory = SearchViewModelFactory()
        return SearchViewModel(
            searchService: factory.searchService,
            imageService: factory.imageService
        )
    }
}
