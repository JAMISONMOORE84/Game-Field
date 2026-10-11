import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AccountView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var isEditingUsername = false
    @State private var newUsername = ""
    @State private var errorMessage = ""
    @State private var showSavedMessage = false

    private let db = Firestore.firestore()

    private var user: User? {
        Auth.auth().currentUser
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.gradient)
                                .frame(width: 110, height: 110)

                            Image(systemName: "person.fill")
                                .font(.system(size: 54))
                                .foregroundStyle(.white)
                        }

                        Text(username.isEmpty ? "Game Field Player" : username)
                            .font(.title2.bold())

                        Text(email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("GAME FIELD MEMBER")
                            .font(.caption2.bold())
                            .tracking(2)
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 28)

                    VStack(alignment: .leading, spacing: 18) {
                        Text("Account Information")
                            .font(.headline)

                        accountRow(
                            icon: "person.fill",
                            title: "Username",
                            value: username.isEmpty ? "Not set" : username
                        ) {
                            newUsername = username
                            isEditingUsername = true
                        }

                        Divider()

                        accountRow(
                            icon: "envelope.fill",
                            title: "Email Address",
                            value: email.isEmpty ? "Not available" : email
                        )

                        Divider()

                        accountRow(
                            icon: "checkmark.shield.fill",
                            title: "Account Status",
                            value: user == nil ? "Not signed in" : "Active"
                        )

                        Divider()

                        accountRow(
                            icon: "calendar",
                            title: "Member Since",
                            value: memberSince
                        )
                    }
                    .padding(20)
                    .background(
                        Color(uiColor: .secondarySystemGroupedBackground)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Player Details")
                            .font(.headline)

                        Label("Game Field", systemImage: "sportscourt.fill")
                            .foregroundStyle(.primary)

                        Label("Games and Events", systemImage: "trophy.fill")
                            .foregroundStyle(.primary)

                        Label("Messages and Teams", systemImage: "bubble.left.and.bubble.right.fill")
                            .foregroundStyle(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(
                        Color(uiColor: .secondarySystemGroupedBackground)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }

                    if showSavedMessage {
                        Text("Username updated!")
                            .foregroundStyle(.green)
                            .font(.footnote)
                    }
                }
                .padding(20)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadAccount()
            }
            .sheet(isPresented: $isEditingUsername) {
                editUsernameSheet
            }
        }
    }

    private var memberSince: String {
        guard let date = user?.metadata.creationDate else {
            return "Unavailable"
        }

        return date.formatted(date: .abbreviated, time: .omitted)
    }

    private func accountRow(
        icon: String,
        title: String,
        value: String,
        action: (() -> Void)? = nil
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.blue)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.subheadline.weight(.medium))
                    .textSelection(.enabled)
            }

            Spacer()

            if let action {
                Button("Edit", action: action)
                    .font(.subheadline.weight(.semibold))
            }
        }
    }

    private var editUsernameSheet: some View {
        NavigationStack {
            Form {
                Section("Your Username") {
                    TextField("Enter username", text: $newUsername)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section {
                    Text("This username will be saved to your Game Field profile.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Edit Username")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isEditingUsername = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveUsername()
                        }
                    }
                }
            }
        }
    }

    @MainActor
    private func loadAccount() async {
        guard let user else {
            username = "Guest"
            email = ""
            return
        }

        email = user.email ?? ""

        do {
            let document = try await db.collection("users")
                .document(user.uid)
                .getDocument()

            username = document.data()?["username"] as? String
                ?? user.displayName
                ?? "Player"
        } catch {
            username = user.displayName ?? "Player"
            errorMessage = "Could not load saved profile information."
        }
    }

    @MainActor
    private func saveUsername() async {
        guard let user else {
            errorMessage = "No signed-in user was found."
            isEditingUsername = false
            return
        }

        let cleanUsername = newUsername.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard cleanUsername.count >= 3 else {
            errorMessage = "Username must be at least 3 characters."
            return
        }

        do {
            try await db.collection("users")
                .document(user.uid)
                .setData([
                    "username": cleanUsername,
                    "email": user.email ?? "",
                    "updatedAt": Timestamp(date: Date())
                ], merge: true)

            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = cleanUsername
            try await changeRequest.commitChanges()

            username = cleanUsername
            errorMessage = ""
            showSavedMessage = true
            isEditingUsername = false
        } catch {
            errorMessage = "Could not save username: \(error.localizedDescription)"
        }
    }
}

#Preview {
    AccountView()
}
