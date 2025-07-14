import SwiftUI
import ComposableArchitecture

@Reducer
public struct TabsFeature: Sendable {
    @ObservableState
    public struct State: Equatable {
        var selectedTab: TabsElement = .home
        
        var home = RootFeature.State(root: .home(.init()))
        var timer = RootFeature.State(root: .timer(.init()))
        var history = RootFeature.State(root: .history(.init()))
        var profile = RootFeature.State(root: .profile(.init()))
        
        var features: IdentifiedArrayOf<TabsElement> = .init(uniqueElements: TabsElement.allCases)
    }
    
    public enum Action {
        case selectedTabChanged(TabsElement)
       
        case home(RootFeature.Action)
        case timer(RootFeature.Action)
        case history(RootFeature.Action)
        case profile(RootFeature.Action)
    }
    
    public var body: some ReducerOf<Self> {
        CombineReducers {
            Scope(state: \.home, action: \.home) { RootFeature() }
            Scope(state: \.timer, action: \.timer) { RootFeature() }
            Scope(state: \.history, action: \.history) { RootFeature() }
            Scope(state: \.profile, action: \.profile) { RootFeature() }
        }
        Reduce { state, action in
            switch action {
            case let .selectedTabChanged(newValue):
                state.selectedTab = newValue
                switch newValue {
                case .home:
                    return .send(.home(.parent(.popToRoot)))
                case .timer:
                    return .send(.timer(.parent(.popToRoot)))
                case .history:
                    return .send(.history(.parent(.popToRoot)))
                case .profile:
                    return .send(.profile(.parent(.popToRoot)))
                }
            case _:
                return .none
            }
        }
    }
    
    public init() { }
}

struct TabsView: View {
    @Perception.Bindable var store: StoreOf<TabsFeature>
    
    public init(store: StoreOf<TabsFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithPerceptionTracking {
            TabView(selection: $store.selectedTab.sending(\.selectedTabChanged)) {
                WithPerceptionTracking {
                    RoutesView(store: store.scope(state: \.home, action: \.home))
                        .tabItem {
                            Label(
                                title: { Text(TabsElement.home.title) },
                                icon: { Image(systemName: TabsElement.home.imageName)
                                        .renderingMode(.template)
                                }
                            )
                        }
                        .tag(TabsElement.home)
                        .id(TabsElement.home)
                    RoutesView(store: store.scope(state: \.timer, action: \.timer))
                        .tabItem {
                            Label(
                                title: { Text(TabsElement.timer.title) },
                                icon: { Image(systemName: TabsElement.timer.imageName)
                                        .renderingMode(.template)
                                }
                            )
                        }
                        .tag(TabsElement.timer)
                        .id(TabsElement.timer)
                    RoutesView(store: store.scope(state: \.history, action: \.history))
                        .tabItem {
                            Label(
                                title: { Text(TabsElement.history.title) },
                                icon: { Image(systemName: TabsElement.history.imageName)
                                        .renderingMode(.template)
                                }
                            )
                        }
                        .tag(TabsElement.history)
                        .id(TabsElement.history)
                    RoutesView(store: store.scope(state: \.profile, action: \.profile))
                        .tabItem {
                            Label(
                                title: { Text(TabsElement.profile.title) },
                                icon: { Image(systemName: TabsElement.profile.imageName)
                                        .renderingMode(.template)
                                }
                            )
                        }
                        .tag(TabsElement.profile)
                        .id(TabsElement.profile)
                }
            }
            .tint(Color("primary"))
        }
    }
}
