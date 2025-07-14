import Foundation

public struct HomeViewModel: Equatable {
    public var statistics: [WorkoutType: WorkoutStatistics]
    public var recentWorkouts: [WorkoutModel]
    public var activeStatisticSection: WorkoutType
    
    init(
        statistics: [WorkoutType : WorkoutStatistics],
        recentWorkouts: [WorkoutModel]
    ) {
        self.statistics = statistics
        self.recentWorkouts = recentWorkouts
        self.activeStatisticSection = .all
    }
}

extension HomeViewModel {
    public static var empty: Self {
        .init(
            statistics: [:],
            recentWorkouts: []
        )
    }
}
