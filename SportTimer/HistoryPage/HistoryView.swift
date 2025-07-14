import SwiftUI
import ComposableArchitecture

struct HistoryView: View {
    @Perception.Bindable var store: StoreOf<HistoryFeature>
    
    public init(store: StoreOf<HistoryFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                if store.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    if store.viewModel.groupedWorkouts.isEmpty {
                        Spacer()
                        Text("No workouts yet")
                            .foregroundColor(.secondary)
                        Spacer()
                    } else {
                        List {
                            ForEach(store.viewModel.groupedWorkouts) { group in
                                Section {
                                    ForEach(group.workouts.sorted(by: { $0.date > $1.date })) { workout in
                                        workoutRow(workout)
                                    }
                                } header: {
                                    Text(group.title)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                        .listStyle(.grouped)
                    }
                }
            }
            .navigationTitle(Text("History View"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear{
                store.send(.ui(.onApear))
            }
        }
    }
    
    @ViewBuilder
    private func workoutRow(_ workout: WorkoutModel) -> some View {
        VStack {
            HStack {
                Text(workout.type.title)
                Spacer()
                Text(workout.totalDurationFormatted)
            }
            Text(workout.date.formatted(.dateTime.day().month(.wide).year()))
            Text(workout.notes)
        }
        .contextMenu {
            Button {
                store.send(.ui(.deleteWorkout(workout)))
            } label: {
                Label("Удалить", systemImage: "trash")
            }
            .foregroundStyle(.red)
        }
    }
}

#Preview {
    HistoryView(
        store: Store(
            initialState: HistoryFeature.State(),
            reducer: {
                HistoryFeature()
                    ._printChanges()
            }
        )
    )
}
