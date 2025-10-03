//
//  AuthViewModel.swift
//  FinanceApp
//
//  Created by Tina  on 9.02.25.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    
    private let db = Firestore.firestore()
    
    func register(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error)
                return
            }

            guard let user = authResult?.user else {
                completion(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }

            // Send the verification email
            user.sendEmailVerification { error in
                if let error = error {
                    completion(error)
                    return
                }
                // Verification email sent successfully

                // Save user info in Firestore
                let userData: [String: Any] = [
                    "email": email,
                    "userID": user.uid,
                    "createdAt": Timestamp()
                ]

                self.db.collection("users").document(user.uid).setData(userData, merge: true) { error in
                    if error == nil {
                        // ✅ Set isAuthenticated to true (this triggers redirect to TabUIView)
                      //  UserDefaults.standard.set(true, forKey: "isAuthenticated")
                        UserDefaults.standard.set(email, forKey: "email")  // Optional: Save email
                    }
                    completion(error)
                }
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let user = authResult?.user else {
                completion(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }
            
            // Fetch user data from Firestore
            self.db.collection("users").document(user.uid).getDocument { document, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                if let document = document, document.exists {
                    let data = document.data()
                    print("User Data: \(data ?? [:])")  // Debugging
                }
                completion(nil)
            }
        }
    }
        
    func logout(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(nil)  // Successfully signed out
        } catch let error {
            completion(error)  // Handle any error if sign-out fails
        }
    }
        
    func checkIfUserIsVerified() -> Bool {
        if let user = Auth.auth().currentUser {
            return user.isEmailVerified
        }
        return false
    }
    
    func sendPasswordReset(email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
    
    func deleteAccount(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
            guard let user = Auth.auth().currentUser else {
                completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])))
                return
            }

            let userId = user.uid
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)

            // ✅ Corrected reauthentication syntax
            user.reauthenticate(with: credential) { _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                // Step 1: Delete user goals from Firestore
                let goalsRef = self.db.collection("spending_goals").whereField("userId", isEqualTo: userId)
                goalsRef.getDocuments { snapshot, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    let batch = self.db.batch()
                    snapshot?.documents.forEach { batch.deleteDocument($0.reference) }

                    batch.commit { error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }

                        // Step 2: Delete user document from Firestore
                        self.db.collection("users").document(userId).delete { error in
                            if let error = error {
                                completion(.failure(error))
                                return
                            }

                            // Step 3: Delete user from Firebase Authentication
                            user.delete { error in
                                if let error = error {
                                    completion(.failure(error))
                                } else {
                                    completion(.success(()))
                                }
                            }
                        }
                    }
                }
            }
        }
}

extension AuthViewModel {
    func changePassword(currentPassword: String, newPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)

        // Re-authenticate user before changing password
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // Update password
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}

