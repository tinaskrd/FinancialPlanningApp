//
//  ProfileViewModel.swift
//  FinanceApp
//
//  Created by Tina  on 19.02.25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    @Published var user: UserModel?
    @Published var isEmailVerified: Bool = false
    
    private var db = Firestore.firestore()
    
    func fetchUserData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else { return }
            
            DispatchQueue.main.async {
                self.user = UserModel(
                    id: userID,
                    bank: data["bank"] as? String ?? "Unknown",
                    email: data["email"] as? String ?? "No email",
                    createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                )
                self.checkEmailVerification()
            }
        }
    }
    
    func checkEmailVerification() {
        if let user = Auth.auth().currentUser {
            self.isEmailVerified = user.isEmailVerified
        }
    }
}

