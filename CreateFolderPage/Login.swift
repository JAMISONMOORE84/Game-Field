import SwiftUI
import FirebaseAuth

struct Login: View {
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

                Text("Log In")
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .offset(y: -100)
                    .foregroundColor(.white)
                    .padding(.bottom, 32)

                VStack {
                    TextField("Email Address", text: $emailInput)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding()
                        .offset(y: 25)

                    SecureField("Password", text: $passwordInput)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                        .padding()
                        .offset(y: 20)

                    if let authErrorMessage {
                        Text(authErrorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button(action: logIn) {
                        HStack {
                            if isAuthenticating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "arrow.right")
                                Text("Log In")
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
                    .padding(.top, 32)
                }
            }
        }
        .navigationDestination(isPresented: $isAuthenticated) {
            ContentView()
        }
    }

    private func logIn() {
        let email = emailInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !email.isEmpty, !password.isEmpty else {
            authErrorMessage = "Enter your email and password."
            return
        }

        isAuthenticating = true
        authErrorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) { _, error in
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

#Preview {
    Login()
}
