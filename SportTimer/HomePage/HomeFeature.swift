import Foundation
import ComposableArchitecture

@Reducer
public struct HomeFeature: Sendable {
    @ObservableState
    public struct State: Equatable {
        var isLoading: Bool = false
        var viewModel: HomeViewModel = .empty
        init() { }
    }
    
    @CasePathable
    public enum Action: BindableAction {
        case ui(UI)
        case data(Data)
        case binding(BindingAction<State>)
        
        @CasePathable
        public enum UI {
            case onApear
            case startWorkoutTapped
        }
        
        @CasePathable
        public enum Data {
            case loadStatistic(OperationStatus<HomeViewModel, Error>)
        }
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .ui(uiAction):
                switch uiAction {
                case .onApear:
                    return getStatistic()
                case .startWorkoutTapped:
                    return .none
                }
            case let .data(dataAction):
                switch dataAction {
                case let .loadStatistic(action):
                    switch action {
                    case .start:
                        state.isLoading = true
                        return .none
                    case .complete:
                        state.isLoading = false
                        return .none
                    case .fail:
                        state.isLoading = false
                        return .none
                    }
                }
            case .binding:
                return .none
            }
        }
    }
    
    private func getStatistic() -> Effect<Action> {
        return .run { send in
            do {
                await send(.data(.loadStatistic(.start)))
                let statistics = try await CoreDataManager.shared.getStatisticsByType()
                let recentWorkouts = try await CoreDataManager.shared.getRecentWorkouts()
                let model = HomeViewModel(
                    statistics: statistics,
                    recentWorkouts: recentWorkouts
                )
                await send(.data(.loadStatistic(.complete(model))))
            } catch {
                print(error)
                await send(.data(.loadStatistic(.fail(error))))
            }
        }
    }
}
