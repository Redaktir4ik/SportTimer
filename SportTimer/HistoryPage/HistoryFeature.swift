import Foundation
import ComposableArchitecture

@Reducer
public struct HistoryFeature: Sendable {
    @ObservableState
    public struct State: Equatable {
        var isLoading: Bool = false
        var viewModel: HistoryViewModel = .init()
        
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
            case deleteWorkout(WorkoutModel)
        }
        
        @CasePathable
        public enum Data {
            case loadWorkout(OperationStatus<HistoryViewModel, Error>)
        }
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .ui(uiAction):
                switch uiAction {
                case .onApear:
                    return .none
                case .deleteWorkout(_):
                    return .none
                }
            case let .data(dataAction):
                switch dataAction {
                case let .loadWorkout(action):
                    switch action {
                    case .start:
                        state.isLoading = true
                        return .none
                    case let .complete(workout):
                        state.isLoading = false
                        state.viewModel = workout
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
    
    private func getAllWorkout() -> Effect<Action> {
        return .run { send in
            do {
                await send(.data(.loadWorkout(.start)))
                let workouts = try await CoreDataManager.shared.getAllWorkouts()
                let model = HistoryViewModel(workouts: workouts)
                await send(.data(.loadWorkout(.complete(model))))
            } catch {
                print(error)
                await send(.data(.loadWorkout(.fail(error))))
            }
        }
    }
}
