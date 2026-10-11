import SwiftUI

struct SettingsTabView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    NavigationLink(destination: AccountView()) {
                        Label("Profile", systemImage: "person.circle")
                    }
                    Label("Notifications", systemImage: "bell")
                    }
                    
                    Section("App") {
                        Label("Appearance", systemImage: "paintbrush")
                        Label("Privacy", systemImage: "hand.raised")
                    }
                    
                    Section {
                        Label("About Game Field", systemImage: "info.circle")
                    }
                }
                .navigationTitle("Settings")
            }
        }
    }


#Preview {
    SettingsTabView()
}
