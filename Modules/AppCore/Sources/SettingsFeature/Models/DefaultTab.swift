import AppFeatures
import SwiftUI

public enum DefaultTab: String, CaseIterable {
    case discover
    case search
    case recentlyViewed

    public var tab: AppTab {
        switch self {
        case .discover:       return .discover
        case .search:         return .search
        case .recentlyViewed: return .recentlyViewed
        }
    }

    public var label: LocalizedStringResource {
        switch self {
        case .discover:       return "tab.discover"
        case .search:         return "tab.search"
        case .recentlyViewed: return "tab.recentlyViewed"
        }
    }
}
