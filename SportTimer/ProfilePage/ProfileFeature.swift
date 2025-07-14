import Foundation
import ComposableArchitecture

@Reducer
public struct ProfileFeature: Sendable {
    @ObservableState
    public struct State: Equatable {
        var isLoading: Bool = false
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
        }
        
        @CasePathable
        public enum Data {
            case load(OperationStatus<Void, Error>)
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
                }
            case let .data(dataAction):
                switch dataAction {
                case let .load(action):
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
}
