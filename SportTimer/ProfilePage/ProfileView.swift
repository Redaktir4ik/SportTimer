import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
    @Perception.Bindable var store: StoreOf<ProfileFeature>
    
    public init(store: StoreOf<ProfileFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
               Text("History View")
            }
            .navigationTitle(Text("History View"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear{
                store.send(.ui(.onApear))
            }
        }
    }
}

#Preview {
    ProfileView(
        store: Store(
            initialState: ProfileFeature.State(),
            reducer: {
                ProfileFeature()
                    ._printChanges()
            }
        )
    )
}
