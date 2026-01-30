import Foundation
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

class FirebaseManager {
    static let shared = FirebaseManager()
    
    // Use the correct database URL for your region
    var database: DatabaseReference {
        let databaseURL = "https://colour-matching-game-default-rtdb.asia-southeast1.firebasedatabase.app/"
        return Database.database(url: databaseURL).reference()
    }
    
    // Check current authentication status
    func checkAuthStatus() {
        if let user = Auth.auth().currentUser {
            print("✅ Currently authenticated with UID: \(user.uid)")
        } else {
            print("❌ No authenticated user. Signing in anonymously...")
            signInAnonymously { error in
                if let error = error {
                    print("❌ Anonymous sign-in failed: \(error.localizedDescription)")
                } else {
                    print("✅ Anonymous sign-in successful")
                }
            }
        }
    }
    
    // Save high score to Firebase
    func saveHighScore(_ highScore: HighScore, completion: @escaping (Error?) -> Void) {
        // Check if user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user - attempting anonymous sign-in...")
            Auth.auth().signInAnonymously { [weak self] authResult, error in
                if let error = error {
                    print("❌ Anonymous sign-in error: \(error.localizedDescription)")
                    completion(error)
                } else if let user = authResult?.user {
                    print("✅ Anonymous sign-in successful. Now saving score with UID: \(user.uid)")
                    self?.saveHighScore(highScore, completion: completion)
                }
            }
            return
        }
        
        print("📤 Saving score for user: \(userId)")
        print("📊 Score details - Name: \(highScore.name), Score: \(highScore.score), Mode: \(highScore.mode)")
        
        let highScoreData: [String: Any] = [
            "name": highScore.name,
            "score": highScore.score,
            "mode": highScore.mode,
            "date": ISO8601DateFormatter().string(from: highScore.date),
            "timestamp": Date().timeIntervalSince1970
        ]
        
        database.child("users").child(userId).child("highScores").childByAutoId().setValue(highScoreData) { error, _ in
            if let error = error {
                print("❌ Firebase Database Error: \(error.localizedDescription)")
            } else {
                print("✅ Score saved to Firebase successfully!")
            }
            completion(error)
        }
    }
    
    // Fetch high scores from Firebase
    func fetchHighScores(for mode: String, completion: @escaping ([HighScore]?, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No user ID for fetching scores")
            completion(nil, NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]))
            return
        }
        
        print("📥 Fetching scores for mode: \(mode)")
        
        database.child("users").child(userId).child("highScores")
            .queryOrdered(byChild: "mode")
            .queryEqual(toValue: mode)
            .observeSingleEvent(of: .value) { snapshot in
                var highScores: [HighScore] = []
                
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                       let value = snapshot.value as? [String: Any],
                       let name = value["name"] as? String,
                       let score = value["score"] as? Int,
                       let mode = value["mode"] as? String,
                       let dateString = value["date"] as? String {
                        
                        let formatter = ISO8601DateFormatter()
                        let date = formatter.date(from: dateString) ?? Date()
                        
                        let highScore = HighScore(name: name, score: score, mode: mode, date: date)
                        highScores.append(highScore)
                    }
                }
                
                highScores.sort { $0.score > $1.score }
                print("✅ Fetched \(highScores.count) scores for mode: \(mode)")
                completion(highScores, nil)
            } withCancel: { error in
                print("❌ Error fetching scores: \(error.localizedDescription)")
                completion(nil, error)
            }
    }
    
    // Sign in anonymously
    func signInAnonymously(completion: @escaping (Error?) -> Void) {
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                print("❌ Anonymous sign-in failed: \(error.localizedDescription)")
                completion(error)
            } else if let user = authResult?.user {
                print("✅ Anonymous sign-in successful with UID: \(user.uid)")
                completion(nil)
            }
        }
    }
}
