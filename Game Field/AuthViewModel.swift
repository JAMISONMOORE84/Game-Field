import SwiftUI
import FirebaseAuth
import Combine

#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

class AuthViewModel: ObservableObject {
    func signInWithGoogle() {
        #if canImport(GoogleSignIn)
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = scene.windows.first?.rootViewController else {
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error {
                print("Google Sign-In failed: \(error.localizedDescription)")
                return
            }

            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { _, error in
                if let error {
                    print("Firebase failed: \(error.localizedDescription)")
                    return
                }

                print("Successfully authenticated!")
            }
        }
        #else
        print("Add the GoogleSignIn Swift package to enable Google login.")
        #endif
    }
}
