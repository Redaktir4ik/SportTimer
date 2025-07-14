import Foundation
import ComposableArchitecture

@Reducer
public struct TimerFeature: Sendable {
   public enum TimerStatus: Equatable {
        case running
        case paused
        case stopped
    }
    
    @ObservableState
    public struct State: Equatable {
        var isLoading: Bool = false
        var workout: WorkoutModel = .empty
        var timerState: TimerStatus = .stopped
        var endTime: Date = Calendar.current.startOfDay(for: Date.now)
        var currentTimeString: String = "00:00"
        var currentTimeInterval: Int = 0
        var progress: Double = 1
        
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
            case changeEndTime
            case timerChangeStatus(TimerStatus)
            case timerTicked
        }
        
        @CasePathable
        public enum Data {
            case saveWorkout(OperationStatus<Void, Error>)
        }
    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.audioPlayer) var audioPlayer
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .ui(uiAction):
                switch uiAction {
                case .onApear:
                    return .none
                case .changeEndTime:
                    let duration: Int = Int(state.endTime.timeIntervalSince(Calendar.current.startOfDay(for: Date.now)))
                    state.currentTimeString = timeToString(duration)
                    state.currentTimeInterval = duration
                    state.workout.duration = duration
                    return .none
                case let .timerChangeStatus(status):
                    state.timerState = status
                    switch status {
                    case .paused:
                        audioPlayer.playSound(.pause)
                        return .cancel(id: CancelTimer.timer)
                    case .running:
                        audioPlayer.playSound(.start)
                        return .run { send in
                            for await _ in mainQueue.timer(interval: 1) {
                                await send(.ui(.timerTicked))
                            }
                        }
                        .cancellable(id: CancelTimer.timer)
                    case .stopped:
                        state.timerState = .stopped
                        state.workout.duration -= state.currentTimeInterval
                        audioPlayer.playSound(.stop)
                        return .cancel(id: CancelTimer.timer)
                            .merge(with: createWorkout(workout: state.workout))
                    }
                case .timerTicked:
                    state.currentTimeInterval -= 1
                    state.currentTimeString = timeToString(state.currentTimeInterval)
                    state.progress = Double(state.currentTimeInterval) / Double(state.workout.duration)
                    if state.currentTimeInterval <= 0 {
                        state.currentTimeInterval = 0
                        state.currentTimeString = timeToString(0)
                        return .send(.ui(.timerChangeStatus(.stopped)))
                    }
                    return .none
                }
            case let .data(dataAction):
                switch dataAction {
                case let .saveWorkout(action):
                    switch action {
                    case .start:
                        state.isLoading = true
                        return .none
                    case .complete:
                        state.isLoading = false
                        state.workout = .empty
                        state.timerState = .stopped
                        state.endTime = Calendar.current.startOfDay(for: Date.now)
                        state.currentTimeString = "00:00"
                        state.currentTimeInterval = 0
                        state.progress = 1
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
    
    private func createWorkout(workout: WorkoutModel) -> Effect<Action> {
        return .run { send in
            do {
                await send(.data(.saveWorkout(.start)))
                try await CoreDataManager.shared.createWorkout(workout)
                await send(.data(.saveWorkout(.complete(()))))
            } catch {
                print(error)
                await send(.data(.saveWorkout(.fail(error))))
            }
        }
    }
    
    private func timeToString(_ duration: Int) -> String {
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        if hours == 0 {
            return String(format: "%02d:%02d", minutes, seconds)
        } else {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
}

private enum CancelTimer: Hashable {
    case timer
}
