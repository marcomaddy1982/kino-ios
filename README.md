# iOS Kino App

## Overview

The project is structured around the following key technical decisions:

- [Custom networking library built on `async/await`](#1-networking-library)
- [Swift 6 strict concurrency](#2-swift-6-concurrency)
- [Lightweight dependency injection via `@Injected`](#3-dependency-injection-library)
- [Secure configuration management via `.xcconfig`](#4-configuration--secret-management)
- [MVVM with protocol-backed ViewModels and container views](#5-mvvm-architecture)
- [Dedicated service layer](#6-service-layer)
- [Offline cache with SwiftData and Repository pattern](#7-offline-cache-with-swiftdata)
- [Design System](#8-design-system)
- [Localisation](#9-localisation)
- [Dynamic Type](#10-dynamic-type)
- [Dark Mode](#11-dark-mode)
- [Combine-powered search autocomplete](#12-search-autocomplete-with-combine)
- [Unit tests for ViewModels and Request Builder](#13-testing)

---

## 1. Networking Library

A lightweight networking library handles all API communication. It supports `GET`, `POST`, `PUT`, `PATCH`, and `DELETE`, covering the full range of RESTful operations.

### Why `async/await`

Completion blocks and Combine/Promises were considered and set aside in favour of `async/await` for the following reasons:

- **Readability**: Async code reads like synchronous code.
- **Error handling**: `async throws` integrates naturally with `do/try/catch`.
- **Composability**: Calls can be sequenced or parallelised via `.task` modifiers or `Task` blocks.
- **First-class Swift support**: Aligns with Apple's own modern APIs (e.g. `URLSession.data(for:)`).
- **Cancellation**: Built-in cooperative cancellation via `Task`.

### Error Handling

The library defines a typed error enum (`NetworkError`) covering common failure scenarios: HTTP errors (4xx, 5xx), decoding failures, timeouts, and configuration issues. Callers always receive a meaningful error.

---

## 2. Swift 6 Concurrency

The project runs with **Swift 6 strict concurrency enabled** (`SWIFT_STRICT_CONCURRENCY = complete`), which enforces data-race safety at compile time rather than at runtime.

### Benefits

- **Compile-time safety**: Data races are caught as build errors.
- **Explicit contracts**: `Sendable` conformance makes threading assumptions visible in the type system.
- **Actor isolation**: `actor` types and `@MainActor` guarantee state protection and correct thread usage.
- **Future-proof**: Avoids a costly migration to Swift 6 requirements later.

---

## 3. Dependency Injection Library

A custom DI library built on `@propertyWrapper` exposes an `@Injected` API across the codebase. Dependencies are registered once at app launch and resolved anywhere via the property wrapper.

```swift
// Registration (once, at app launch in setupDependencies)
let networkClient = NetworkClient(config: config)
DIContainer.shared.register(networkClient)

// Resolution (in ViewModelFactory)
@Injected<NetworkClient> var networkClient: NetworkClient
@Injected<MovieServiceProtocol> var movieService
```

### Benefits

- **Single registration point**: All wiring lives in one place; swapping an implementation is a single change.
- **No manual passing**: Eliminates dependency chains through initializer parameters.
- **Protocol-backed**: Makes mock injection straightforward for tests.
- **Singleton-like lifetime**: Instances are created once and reused, without the pitfalls of global state.

---

## 4. Configuration & Secret Management

Sensitive values (API base URL, API token) are managed via `.xcconfig` files (excluded from version control, source of truth) and substituted into `Config.plist` at build time.

### Benefits

- **Security**: Secrets never appear in committed source code.
- **Environment separation**: Separate `.xcconfig` files per scheme (`Debug`, `Staging`, `Release`).
- **No code changes for config**: Updating an endpoint or token requires no Swift changes.
- **CI/CD friendly**: Pipelines can inject values as secrets without touching the repository.

---

## 5. MVVM Architecture

The project uses MVVM with SwiftUI's `ObservableObject` / `@StateObject`. ViewModels are created via a **Factory** pattern. Services are injected via **protocols** (e.g., `MovieServiceProtocol`, `ImageServiceProtocol`), enabling testability and mock injection.

### Factory Pattern

```swift
@MainActor
final class MovieListViewModelFactory {
    @Injected<MovieServiceProtocol> var movieService
    @Injected<ImageServiceProtocol> var imageService
    
    static func makeMovieListViewModel() -> MovieListViewModel {
        let factory = MovieListViewModelFactory()
        return MovieListViewModel(movieService: factory.movieService, imageService: factory.imageService)
    }
}
```

### Container View Pattern

Each screen is split into a **container view** and a set of **state-specific subviews**. The container owns the `@StateObject`, handles navigation via `.task` modifiers, and switches between subviews based on the ViewModel's current state.

### Benefits

- **Separation of concerns**: Views are purely declarative; all logic lives in the ViewModel.
- **`@StateObject` ownership**: The view correctly owns the ViewModel lifecycle.
- **Factory pattern**: ViewModel creation is centralised and decoupled from the view.
- **Decoupled subviews**: Each state maps to a focused, self-contained view.
- **Testability**: Services are injected via protocols, enabling mock injection for isolated ViewModel testing without network calls.

---

## 6. Service Layer

A dedicated Service layer sits between the ViewModels and the networking library. Each service owns one domain area and exposes `async throws` methods.

### Responsibilities

- Calling the networking library with the correct endpoint and parameters.
- Decoding API responses into typed model objects.
- Acting as the single point of change for API contract updates.

### Benefits

- **Single Responsibility**: ViewModels stay free of networking details.
- **Reusability**: Multiple ViewModels can share the same service.
- **Testability**: Services are injected via protocols and can be mocked in isolation.
- **Consistency**: The same `async/await` model flows uniformly from network to ViewModel.

---

## 7. Offline Cache with SwiftData

A caching layer is implemented via a **Repository** pattern. The repository sits between the ViewModel and the service, and is responsible for deciding whether to return cached data from a local SwiftData store or fetch fresh data from the network.

SwiftData backs two persistence needs in the app:

- **Movie list cache**: Popular movies are cached locally so the list is available immediately on relaunch without a network round-trip.
- **Recently Viewed history**: Movies opened by the user are saved to a SwiftData store and surfaced in the Recently Viewed tab.

### Why SwiftData

- **Native Swift API**: Built on Swift macros, integrates seamlessly with SwiftUI and Swift concurrency.
- **Minimal boilerplate**: Models are declared with `@Model`, no manual schema definitions needed.
- **Type safety**: Queries and relationships are fully typed.
- **SwiftUI integration**: The `@Query` macro makes persisted data observable directly in views.

### Why the Repository Pattern

- **Single decision point**: Cache-or-network logic lives in one place, invisible to the ViewModel.
- **Transparent to the ViewModel**: Called exactly like a service — no changes needed above this layer.
- **Easily testable**: Conforms to a protocol, so it can be mocked like any other dependency.
- **Flexible strategy**: Cache invalidation rules can evolve inside the repository without touching the rest of the codebase.

---

## 8. Design System

A dedicated `DesignSystem` module centralises colors (`AppColors`), typography (`AppFonts`, `TextStyles`), and reusable components. Color tokens map to named asset catalog entries, font tokens use `Font.TextStyle`, and components accept `LocalizedStringKey` — keeping views free of raw values and boilerplate.

### Benefits

- **Single source of truth**: A color or font change propagates everywhere automatically.
- **Composability**: Components are small, focused, and combine freely.
- **Consistency**: No ad-hoc styling in feature views.
- **Maintainability**: Adding a new screen requires no design decisions — tokens and components provide the answers.

---

## 9. Localisation

Strings are managed in one `Localizable.xcstrings` catalog per module (`en` + `it`), looked up through that module's own bundle. Keys follow a `feature.context` convention so copy can change without touching the codebase. Components take `LocalizedStringResource`; dynamic values are localised at the ViewModel layer via `String(localized:)`.

### Benefits

- **Compile-time coverage**: Missing translations are build warnings, not silent runtime blanks.
- **Maintainability**: All strings for all languages live in one file — no hunting across `.strings` files.
- **Clean call sites**: Feature views pass string literals directly; the framework handles resolution.

---

## 10. Dynamic Type

All fonts use `Font.system(.textStyle)` and layout values use `@ScaledMetric(relativeTo:)` so text and surrounding space scale proportionally from Extra Small to Accessibility 5. The movie list and search grid collapse from two columns to one at `>= .accessibility1`.

### Benefits

- **Inclusivity**: Users with visual impairments who rely on large text sizes get a fully functional layout, not a broken one.
- **Zero runtime cost**: Scaling is handled by the framework — no custom logic required.
- **Proportional layout**: `@ScaledMetric` ensures spacing grows and shrinks in proportion with text, not independently.

---

## 11. Dark Mode

Every color token maps to a named asset catalog color set with explicit light and dark variants. An in-app appearance picker (System / Light / Dark) persists the choice via `@AppStorage` and applies it at the window root via `.preferredColorScheme()`.

### Benefits

- **Full customisation preserved**: Both light and dark values are explicit design decisions, not system color approximations.
- **User control**: The in-app override lets users keep the app dark while the phone is in light mode, or vice versa.
- **Automatic resolution**: SwiftUI handles variant selection — no `if colorScheme == .dark` conditionals in views.

---

## 12. Search Autocomplete with Combine

Search is powered by Combine, with the query string exposed as a `@Published` property on the ViewModel. Two separate Combine pipelines drive the behaviour:

- **Search pipeline**: Listens to query changes, applies `debounce` (waits for a pause after typing) and `removeDuplicates` (skips if value is unchanged), then triggers the search request.
- **Clear pipeline**: Listens for empty queries (user tapped clear), triggering an immediate reset of results without debounce.

### Benefits

- **Reduced network load**: Search pipeline's `debounce` fires only when the user pauses typing.
- **No redundant calls**: `removeDuplicates` skips requests when the value hasn't changed.
- **Separate concerns**: Search and clear logic flow through dedicated pipelines, centralised in the ViewModel.
- **Clean view**: The view only updates `viewModel.searchQuery` — all reactive logic is handled downstream.

---

## 13. Testing

Unit tests cover two key areas: **ViewModels** and the **Request Builder**.

ViewModels are tested in isolation by injecting mock services conforming to the same protocols used in production. This allows tests to control the data the ViewModel receives and assert on its output state without any networking or side effects involved.

The Request Builder is tested by asserting that given a set of inputs (endpoint, parameters, HTTP method), the resulting `URLRequest` is correctly constructed — right URL, headers, and method. This validates the core of the networking layer independently from any live API.

### Benefits

- **Fast and deterministic**: No network calls — tests run instantly and always produce the same result.
- **High confidence at low cost**: Covers the two most logic-heavy components of the codebase.
- **Mocks are free**: Protocol-backed types require no extra abstraction to be testable.
- **Regression safety**: Breaking changes to request construction or ViewModel logic are caught immediately.

---

*README written as part of the iOS technical challenge submission.*
