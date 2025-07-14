import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    @Perception.Bindable var store: StoreOf<HomeFeature>
    
    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    
                    startWorkoutButton
                    
                    recentWorkoutsSection
                }
                .padding()
            }
            .navigationTitle(Text("Home View"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear{
                store.send(.ui(.onApear))
            }
        }
    }
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Приветствуем вас в приложении")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            VStack(spacing: 24) {
                HStack {
                    Picker(
                        store.viewModel.activeStatisticSection.title,
                        selection: $store.viewModel.activeStatisticSection
                    ) {
                        ForEach(WorkoutType.allCases) { type in
                            Text(type.title)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    if let section = store.viewModel.statistics[store.viewModel.activeStatisticSection] {
                        Text("Всего времени на тренировках: \(section.totalDurationFormatted)")
                            .frame(maxWidth: .infinity)
                        Text("Всего тренировок: \(section.workoutCount)")
                            .frame(maxWidth: .infinity)
                    }
                    else {
                        Text("Пока небыло тренировок")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var startWorkoutButton: some View {
        Button {
            store.send(.ui(.startWorkoutTapped))
        } label: {
            Text("Начать тренировку")
                .font(.title2.bold())
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Последние тренировки")
                .font(.title3.bold())
            
            LazyVStack(alignment: .leading, spacing: 16) {
                if store.viewModel.recentWorkouts.count != 0 {
                    ForEach(store.viewModel.recentWorkouts) { workout in
                        WorkoutCardView(model: workout)
                    }
                } else {
                    Text("Пока небыло тренировок.")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HomeView(
        store: Store(
            initialState: HomeFeature.State(),
            reducer: {
                HomeFeature()
                    ._printChanges()
            }
        )
    )
}
