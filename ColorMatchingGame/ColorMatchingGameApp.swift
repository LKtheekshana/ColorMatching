import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct ColorMatchingGameApp: App {
    init() {
        // Configure Firebase FIRST
        FirebaseApp.configure()
        print("🔧 Firebase configured")
        
        // Then authenticate anonymously
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { authResult, error in
                if let error = error {
                    print("❌ Firebase Auth Error: \(error.localizedDescription)")
                } else if let user = authResult?.user {
                    print("✅ Signed in anonymously with UID: \(user.uid)")
                } else {
                    print("⚠️ Auth succeeded but no user returned")
                }
            }
        } else {
            print("✅ Already authenticated with UID: \(Auth.auth().currentUser?.uid ?? "unknown")")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ColorMatchingGame()
        }
    }
}
