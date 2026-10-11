import SwiftUI

struct EventsTabView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)

                Text("Events")
                    .font(.largeTitle.bold())

                Text("Discover upcoming games and events.")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Events")
        }
    }
}
