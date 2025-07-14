import SwiftUI
import ComposableArchitecture

struct TimerView: View {
    @Perception.Bindable var store: StoreOf<TimerFeature>
    @FocusState private var isTextFieldFocused: Bool

    
    public init(store: StoreOf<TimerFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(spacing: 30) {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 20)
                            .opacity(0.3)
                            .foregroundColor(.gray)
                        
                        Circle()
                            .trim(from: 0, to: store.progress)
                            .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .foregroundColor(.blue)
                            .rotationEffect(.degrees(-90))
                        
                        Text(store.currentTimeString)
                            .font(.system(size: 48, weight: .bold))
                    }
                    .frame(width: 250, height: 250)
                    .padding(.top, 20)
                    
                    DatePicker(
                        "Время окончания тренировки",
                        selection: $store.endTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .onChange(of: store.endTime) { _ in
                        store.send(.ui(.changeEndTime))
                    }
                    .disabled(store.timerState != .stopped)
                    
                    Picker("Тип тренировки", selection: $store.workout.type) {
                        ForEach(WorkoutType.workoutCases) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(store.timerState != .stopped)
                    
                    TextField("Описание тренировки", text: $store.workout.notes, axis: .vertical)
                    .padding()
                    .lineLimit(nil)
                    .frame(minHeight: 100, alignment: .topLeading)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    .focused($isTextFieldFocused)
                    .onTapGesture {
                        isTextFieldFocused = true
                    }
                    .disabled(store.timerState != .stopped)
                    
                    // Кнопки управления
                    HStack(spacing: 20) {
                        switch store.timerState {
                        case .running:
                            Button {
                                store.send(.ui(.timerChangeStatus(.paused)))
                            } label: {
                                Text("Пауза")
                            }
                        case .paused:
                            Button {
                                store.send(.ui(.timerChangeStatus(.running)))
                            } label: {
                                Text("Продолжить")
                            }
                        case .stopped:
                            Button {
                                store.send(.ui(.timerChangeStatus(.running)))
                            } label: {
                                Text("Старт")
                            }
                        }
                        
                        Button {
                            store.send(.ui(.timerChangeStatus(.stopped)))
                        } label: {
                            Text("Стоп")
                        }
                        .disabled(store.timerState == .stopped)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding()
            }
            .navigationTitle(Text("Timer"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear{
                store.send(.ui(.onApear))
            }
        }
    }
}

#Preview {
    TimerView(
        store: Store(
            initialState: TimerFeature.State(),
            reducer: {
                TimerFeature()
                    ._printChanges()
            }
        )
    )
}
