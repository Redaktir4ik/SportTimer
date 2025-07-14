import SwiftUI
import ComposableArchitecture

@Reducer
public struct AppFeature: Sendable {
    
    @ObservableState
    public struct State: Equatable {
        var tabs = TabsFeature.State()
        init() { }
    }
    
    @CasePathable
    public enum Action {
        case tabs(TabsFeature.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.tabs, action: \.tabs) {
            TabsFeature()
        }
        Reduce { state, action in
            switch action {
            case .tabs:
                return .none
            }
        }
    }
}

private struct AppFetureView: View {
    @Perception.Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        WithPerceptionTracking {
            TabsView(store: store.scope(state: \.tabs, action: \.tabs))
        }
    }
}

@main
struct AppView: App {
    var body: some Scene {
        WindowGroup {
            AppFetureView(
                store: Store(
                    initialState: AppFeature.State(),
                    reducer: { AppFeature() }
                )
            )
        }
    }
}
