import Foundation

public enum TabsElement: Int, Identifiable, CaseIterable, Equatable {
    public var id: Int { self.rawValue }
    case home
    case timer
    case history
    case profile
    
    public var title: String {
        switch self {
        case .home:
            return "Home"
        case .timer:
            return "Timer"
        case .history:
            return "History"
        case .profile:
            return "Profile"
        }
    }
    
    public var imageName: String {
        switch self {
        case .home:
            return "house"
        case .timer:
            return "timer"
        case .history:
            return "clock"
        case .profile:
            return "person.crop.circle"
        }
    }
}

public enum WorkoutType: String, CaseIterable, Identifiable, Sendable {
    public var id: String { self.rawValue }
    case strength = "Strength"
    case cardio = "Cardio"
    case yoga = "Yoga"
    case stretching = "Stretching"
    case other = "Other"
    case all = "All"
    
    public var title : String {
        switch self {
        case .strength: "Силовая тренировка"
        case .cardio: "Кардио"
        case .yoga: "Йога"
        case .stretching: "Растяжка"
        case .other: "Другое"
        case .all: "Все тренировки"
        }
    }
    public static var workoutCases: [WorkoutType] {
        [.strength, .cardio, .yoga, .stretching, .other]
    }
}
