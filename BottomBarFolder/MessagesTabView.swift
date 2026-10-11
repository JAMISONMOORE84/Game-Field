
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MessagesTabView: View {
    @State private var conversations: [Conversation] = []
    @State private var showAddConversation = false
    @State private var conversationName = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var listener: ListenerRegistration?

    private let db = Firestore.firestore()

    var body: some View {
        NavigationStack {
            Group {
                if Auth.auth().currentUser == nil {
                    ContentUnavailableView(
                        "Not Signed In",
                        systemImage: "person.crop.circle",
                        description: Text(
                            "Sign in to your Game Field account to view messages."
                        )
                    )
                } else if conversations.isEmpty {
                    ContentUnavailableView(
                        "No Conversations",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text(
                            "Tap + to create your first conversation."
                        )
                    )
                } else {
                    List(conversations) { conversation in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(conversation.name)
                                .font(.headline)

                            Text(conversation.lastMessage)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 5)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        conversationName = ""
                        errorMessage = ""
                        showAddConversation = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .disabled(Auth.auth().currentUser == nil)
                }
            }
            .sheet(isPresented: $showAddConversation) {
                addConversationSheet
            }
            .onAppear {
                startListening()
            }
            .onDisappear {
                listener?.remove()
                listener = nil
            }
            .alert("Messages", isPresented: Binding(
                get: { !errorMessage.isEmpty },
                set: { if !$0 { errorMessage = "" } }
            )) {
                Button("OK", role: .cancel) {
                    errorMessage = ""
                }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var addConversationSheet: some View {
        NavigationStack {
            Form {
                Section("New Conversation") {
                    TextField(
                        "Conversation name",
                        text: $conversationName
                    )
                    .textInputAutocapitalization(.words)
                }

                Section {
                    Text(
                        "This creates a conversation for your account. " +
                        "You can add other participants when you build that feature."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAddConversation = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            await createConversation()
                        }
                    }
                    .disabled(
                        conversationName
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .isEmpty || isLoading
                    )
                }
            }
        }
    }

    private func startListening() {
        listener?.remove()
        listener = nil

        guard let userID = Auth.auth().currentUser?.uid else {
            conversations = []
            return
        }

        listener = db.collection("conversations")
            .whereField("participants", arrayContains: userID)
            .addSnapshotListener { snapshot, error in
                if let error {
                    errorMessage = error.localizedDescription
                    return
                }

                guard let documents = snapshot?.documents else {
                    conversations = []
                    return
                }

                conversations = documents.compactMap { document in
                    let data = document.data()

                    guard let name = data["name"] as? String else {
                        return nil
                    }

                    return Conversation(
                        id: document.documentID,
                        name: name,
                        lastMessage: data["lastMessage"] as? String
                            ?? "No messages yet"
                    )
                }
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            }
    }

    @MainActor
    private func createConversation() async {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Sign in before creating a conversation."
            return
        }

        let cleanName = conversationName
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanName.isEmpty else {
            errorMessage = "Enter a conversation name."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let reference = db.collection("conversations").document()

            try await reference.setData([
                "name": cleanName,
                "participants": [user.uid],
                "lastMessage": "No messages yet",
                "updatedAt": Timestamp(date: Date())
            ])

            showAddConversation = false
            conversationName = ""
        } catch {
            errorMessage = "Could not create conversation: \(error.localizedDescription)"
        }
    }
}

private struct Conversation: Identifiable {
    let id: String
    let name: String
    let lastMessage: String
}

#Preview {
    MessagesTabView()
}
