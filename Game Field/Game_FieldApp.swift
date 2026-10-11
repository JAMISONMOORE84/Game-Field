import FirebaseCore
import SwiftUI

#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        return true
    }

}

@main
struct Game_FieldApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    
    var body: some Scene {
        WindowGroup {
            
            CreatePage()
                .onOpenURL { url in
                    #if canImport(GoogleSignIn)
                    GIDSignIn.sharedInstance.handle(url)
                    #endif
                }
        }
    
    WindowGroup("CreateFolderPage", id: "Create") {
        CreatePage()
        
    }
        
    WindowGroup("Game Field", id: "Content") {
        ContentView()
            
    }
        
        WindowGroup("CreateFolderPage", id: "Log") {
            Login()
            
        }
        
        WindowGroup("CreateFolderPage", id: "Sign") {
            SignUp()
            
        }
        
        WindowGroup("SettingsFolder", id: "Account") {
            AccountView()
        }
    }
}
