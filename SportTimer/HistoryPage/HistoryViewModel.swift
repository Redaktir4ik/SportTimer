import Foundation

struct WorkoutGroup: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    var workouts: [WorkoutModel]
    var title: String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Сегодня"
        } else if calendar.isDateInYesterday(date) {
            return "Вчера"
        } else {
            return date.formatted(.dateTime.day().month(.wide).year())
        }
    }
}

public struct HistoryViewModel: Equatable {
    var groupedWorkouts: [WorkoutGroup]
    var findText: String = ""
    
    init(workouts: [WorkoutModel] = []) {
        let grouped = Dictionary(grouping: workouts) { workout in
            Calendar.current.startOfDay(for: workout.date)
        }
        self.groupedWorkouts = grouped.map { key, value in
            WorkoutGroup(date: key, workouts: value)
        }
        .sorted { $0.date > $1.date }
    }
}
