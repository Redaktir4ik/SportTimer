import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
public struct RootFeature: Sendable {
    @Reducer(state: .equatable)
    public enum Path {
        case home(HomeFeature)
    }
    
    @Reducer(state: .equatable)
    public enum Root {
        case home(HomeFeature)
        case timer(TimerFeature)
        case history(HistoryFeature)
        case profile(ProfileFeature)
    }
    
    @ObservableState
    public struct State: Equatable {
        var path = StackState<Path.State>()
        
        public var root: Root.State
        
        public init(root: Root.State) {
            self.root = root
        }
    }
    
    @CasePathable
    public enum Action {
        case path(StackActionOf<Path>)
        case root(Root.Action)
        case parent(Parent)
        
        @CasePathable
        public enum Parent {
            case popToRoot
        }
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.root, action: \.root) { Root.body }
        Reduce { state, action in
            switch action {
            case let .path(pathAction):
                switch pathAction {
                case _:
                    break
                }
                return .none
            case let .root(rootAction):
                switch rootAction {
                case _:
                    break
                }
                return .none
            case .parent(.popToRoot):
                guard !state.path.isEmpty else { return .none }
                state.path = .init()
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

public struct RoutesView: View {
    @Perception.Bindable var store: StoreOf<RootFeature>
    
    public init(store: StoreOf<RootFeature>) {
        self.store = store
    }
    
    public var body: some View {
        tabView
    }
    
    @ViewBuilder
    private var tabView: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                RootView(store: store.scope(state: \.root, action: \.root))
            } destination: { store in
                switch store.case {
                case let .home(store):
                    HomeView(store: store)
                }
            }
        }
    }
}

private struct RootView: View {
    @Perception.Bindable var store: StoreOf<RootFeature.Root>
    
    var body: some View {
        WithPerceptionTracking {
            switch store.case {
            case let .home(store):
                HomeView(store: store)
            case let .timer(store):
                TimerView(store: store)
            case let .history(store):
                HistoryView(store: store)
            case let .profile(store):
                ProfileView(store: store)
            }
        }
    }
}
