import CoreData
import Foundation

public struct WorkoutModel: Identifiable, Equatable, Sendable {
    public var id: UUID
    public var type: WorkoutType
    public var duration: Int
    public var date: Date
    public var notes: String
    
    public var totalDurationFormatted: String {
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        if hours == 0 {
            return String(format: "%02d:%02d", minutes, seconds)
        }
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
extension WorkoutModel {
    public static var empty: WorkoutModel {
        .init(
            id: UUID(),
            type: .other,
            duration: 0,
            date: Date(),
            notes: ""
        )
    }
}

public struct WorkoutStatistics: Codable, Equatable {
    public var totalDuration: Int // Общее время в секундах
    public var workoutCount: Int  // Количество тренировок
    
    public var totalDurationFormatted: String {
        let hours = totalDuration / 3600
        let minutes = (totalDuration % 3600) / 60
        let seconds = totalDuration % 60
        if hours == 0 {
            return String(format: "%02d:%02d", minutes, seconds)
        }
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    init(totalDuration: Int, workoutCount: Int) {
        self.totalDuration = totalDuration
        self.workoutCount = workoutCount
    }
}

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AppDataModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // MARK: - CRUD Operations
    
    // Create
    func createWorkout(_ model: WorkoutModel) async throws -> Void {
        let context = persistentContainer.viewContext
        try await context.perform {
            let entity = Workout(context: context)
            entity.id = UUID() // Генерация нового UUID
            entity.type = model.type.rawValue
            entity.duration = Int32(model.duration)
            entity.date = model.date
            entity.notes = model.notes
            try context.save()
        }
    }
    
    // Read all
    func getAllWorkouts() async throws -> [WorkoutModel] {
        let context = persistentContainer.viewContext
        return try await context.perform { [weak self] in
            let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
            let results = try context.fetch(fetchRequest)
            return results.compactMap { self?.convertToModel(entity: $0) }
        }
    }
    
    // Read by ID
    func getWorkout(by id: UUID) async throws -> WorkoutModel? {
        let context = persistentContainer.viewContext
        return try await context.perform { [weak self] in
            let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            let results = try context.fetch(fetchRequest)
            return results.first.flatMap { self?.convertToModel(entity: $0) }
        }
    }
    
    // Update
    func updateWorkout(_ model: WorkoutModel) async throws -> Void {
        let context = persistentContainer.viewContext
        try await context.perform {
            let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", model.id as CVarArg)
                
            guard let entity = try context.fetch(fetchRequest).first else { return }
            
            entity.type = model.type.rawValue
            entity.duration = Int32(model.duration)
            entity.date = model.date
            entity.notes = model.notes
            try context.save()
        }
    }
    
    // Delete
    func deleteWorkout(by id: UUID)  async throws -> Void {
        let context = persistentContainer.viewContext
        try await context.perform {
            let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            guard let entity = try context.fetch(fetchRequest).first else { return }
            
            context.delete(entity)
            try context.save()
        }
    }
    
    func getRecentWorkouts(limit: Int = 3) async throws -> [WorkoutModel] {
        let context = persistentContainer.viewContext
        return try await context.perform { [weak self] in
            let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
            
            // Сортировка по дате в обратном порядке
            let sortDescriptor = NSSortDescriptor(keyPath: \Workout.date, ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            // Ограничение количества результатов
            fetchRequest.fetchLimit = limit
            let results = try context.fetch(fetchRequest)
            return results.compactMap { self?.convertToModel(entity: $0) }
        }
    }
       
       // Получение статистики по типу тренировки
    func getStatisticsByType() async throws -> [WorkoutType: WorkoutStatistics] {
        let context = persistentContainer.viewContext
        return try await context.perform {
            var statistics: [WorkoutType: WorkoutStatistics] = [:]
            
            let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
            let results = try context.fetch(fetchRequest)
            
            for entity in results {
                guard let typeString = entity.type,
                      let workoutType = WorkoutType(rawValue: typeString) else { continue }
                
                let duration = Int(entity.duration)
                
                if var existingStats = statistics[workoutType] {
                    existingStats.totalDuration += duration
                    existingStats.workoutCount += 1
                    statistics[workoutType] = existingStats
                } else {
                    statistics[workoutType] = WorkoutStatistics(
                        totalDuration: duration,
                        workoutCount: 1
                    )
                }
            }
            let workoutCount = results.count
            var totalDuration = 0
            for entity in results {
                totalDuration += Int(entity.duration)
            }
            
            statistics[.all] = WorkoutStatistics(totalDuration: totalDuration, workoutCount: workoutCount)
            
            return statistics
        }
    }
    
    // MARK: - Private methods
    
    private func convertToModel(entity: Workout) -> WorkoutModel? {
        guard let id = entity.id,
              let typeString = entity.type,
              let type = WorkoutType(rawValue: typeString),
              let date = entity.date else {
            return nil
        }
        
        return WorkoutModel(
            id: id,
            type: type,
            duration: Int(entity.duration),
            date: date,
            notes: entity.notes ?? ""
        )
    }
}
