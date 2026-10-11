import SwiftUI
import FirebaseAuth

struct SignUp: View {
    @State private var userInput: String = ""
    @State private var emailInput: String = ""
    @State private var passwordInput: String = ""
    @State private var authErrorMessage: String?
    @State private var isAuthenticating = false
    @State private var isAuthenticated = false

    var body: some View {
        VStack {
            ZStack {
                Color(hex: 0x28282B)
                    .ignoresSafeArea()

                Image("My-To-Do-ListIconBG")
                    .resizable()
                    .offset(y: -250)
                    .scaledToFit()
                    .frame(width: 200, height: 200)

                Text("Sign Up")
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .offset(y: -100)
                    .foregroundColor(.white)

                TextField("UserName", text: $userInput)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.username)
                    .autocorrectionDisabled()
                    .padding()

                TextField("Email Address", text: $emailInput)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding()
                    .offset(y: 50)

                SecureField("Password", text: $passwordInput)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
                    .padding()
                    .offset(y: 100)

                VStack {
                    if let authErrorMessage {
                        Text(authErrorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button(action: signUp) {
                        HStack {
                            if isAuthenticating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "arrow.right")
                                Text("SignUp")
                            }
                        }
                        .frame(width: 300, height: 44)
                        .font(.title)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .disabled(isAuthenticating)
                }
                .padding(.top, 360)
            }
        }
        .navigationDestination(isPresented: $isAuthenticated) {
            ContentView()
        }
    }

    private func signUp() {
        let username = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            authErrorMessage = "Enter a username, email, and password."
            return
        }

        isAuthenticating = true
        authErrorMessage = nil

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error {
                DispatchQueue.main.async {
                    isAuthenticating = false
                    authErrorMessage = error.localizedDescription
                }
                return
            }

            let changeRequest = result?.user.createProfileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges { error in
                DispatchQueue.main.async {
                    isAuthenticating = false

                    if let error {
                        authErrorMessage = error.localizedDescription
                        return
                    }

                    isAuthenticated = true
                }
            }
        }
    }
}

#Preview {
    SignUp()
}
