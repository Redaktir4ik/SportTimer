import SwiftUI

struct WorkoutCardView: View {
    var model: WorkoutModel
    
    init(model: WorkoutModel) {
        self.model = model
    }
    
    var body: some View {
        VStack {
            Text(model.type.title)
            Text(model.totalDurationFormatted)
        }
    }
}

#Preview {
    WorkoutCardView(model: .empty)
}
