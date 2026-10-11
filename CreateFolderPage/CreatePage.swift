import SwiftUI
import FirebaseAuth
import FirebaseCore

#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255.0,
            green: Double((hex >> 08) & 0xff) / 255.0,
            blue: Double((hex >> 00) & 0xff) / 255.0,
            opacity: opacity
        )
    }
}

struct CreatePage: View {
    @Environment(\.openWindow) private var openWindow
    @State private var authErrorMessage: String?
    @State private var isSigningInWithGoogle = false
    @State private var isAuthenticated = false
    @State private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    var body: some View {
        Group {
            if isAuthenticated {
                ContentView()
            } else {
                NavigationStack {
                    ZStack {
                        Color(hex: 0x28282B)
                            .ignoresSafeArea()
                        
                        Image("My-To-Do-ListIconBG")
                            .resizable()
                            .offset(y: -250)
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                        
                        Text("My To-Do List")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .offset(y: -100)
                            .foregroundColor(.white)
                        
                        VStack {
                            NavigationLink(destination: SignUp()) {
                                HStack {
                                    Image(systemName: "person.badge.plus")
                                    Text("SignUp")
                                }
                                .frame(width: 300, height: 44)
                                .font(.title)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .buttonStyle(.plain)
                            }
                            .offset(y: 7)
                            
                            NavigationLink(destination: Login()) {
                                HStack {
                                    Image(systemName: "lock.open")
                                    Text("Login")
                                }
                                .frame(width: 300, height: 44)
                                .font(.title)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .buttonStyle(.plain)
                            }
                            .offset(y: 40)
                        }
                        
                        VStack(spacing: 12) {
                            HStack {
                                Button(action: { print("Custom photo tapped") }) {
                                    Image("AppleIcon")
                                        .resizable()
                                        .offset(y: 0)
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                }
                                
                                Button(action: { print("Gear icon tapped") }) {
                                    Image("GitHubIcon")
                                        .resizable()
                                        .offset(y: 0)
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                }
                                
                                Button(action: signInWithGoogle) {
                                    ZStack {
                                        Image("GoogleIcon")
                                            .resizable()
                                            .offset(y: 0)
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                            .opacity(isSigningInWithGoogle ? 0.35 : 1)
                                        
                                        if isSigningInWithGoogle {
                                            ProgressView()
                                        }
                                    }
                                }
                                .disabled(isSigningInWithGoogle)
                            }
                            
                            if let authErrorMessage {
                                Text(authErrorMessage)
                                    .font(.footnote)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        .offset(y: 150)
                    }
                }
            }
        }
        
        .onAppear {
            if Auth.auth().currentUser != nil {
                isAuthenticated = true
            }
        }
        
    }
    
    private func signInWithGoogle() {
        #if canImport(GoogleSignIn)
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            authErrorMessage = "Missing Firebase client ID."
            return
        }

        guard let presentingViewController = UIApplication.shared.rootViewController else {
            authErrorMessage = "Unable to open Google sign in."
            return
        }

        isSigningInWithGoogle = true
        authErrorMessage = nil

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error {
                finishGoogleSignIn(errorMessage: error.localizedDescription)
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                finishGoogleSignIn(errorMessage: "Google sign in did not return a valid token.")
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { _, error in
                if let error {
                    finishGoogleSignIn(errorMessage: error.localizedDescription)
                    return
                }

                finishGoogleSignIn(errorMessage: nil)
            }
        }
        #else
        authErrorMessage = "Add the GoogleSignIn Swift package to enable Google login."
        #endif
    }

    private func finishGoogleSignIn(errorMessage: String?) {
        DispatchQueue.main.async {
            isSigningInWithGoogle = false
            authErrorMessage = errorMessage
            isAuthenticated = errorMessage == nil
        }
    }
}

#if canImport(GoogleSignIn)
private extension UIApplication {
    var rootViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
#endif

#Preview {
    CreatePage()
}
