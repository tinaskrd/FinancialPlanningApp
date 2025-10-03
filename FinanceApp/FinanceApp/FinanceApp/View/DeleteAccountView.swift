//
//  DeleteAccountView.swift
//  FinanceApp
//
//  Created by Tina  on 18.03.25.
//

import SwiftUI
import FirebaseAuth

struct DeleteAccountView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var deletionError: String?
    @State private var showSuccessAlert = false  // Add state for success alert
    
    @AppStorage("isAuthenticated") private var isAuthenticated = true  // Track authentication status

    var body: some View {
        VStack {
            Text("Delete Account")
                .font(.largeTitle)
                .padding()

            TextField("Email", text: $email)
                .textInputAutocapitalization(.none)
                .autocorrectionDisabled()
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)

            Button(action: {
                // Call delete account method with email and password
                authViewModel.deleteAccount(email: email, password: password) { result in
                    switch result {
                    case .success:
                        // After successful deletion, log out the user and update isAuthenticated
                        deleteAccount()
                    case .failure(let error):
                        deletionError = error.localizedDescription
                    }
                }
            }) {
                Text("Delete Account")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .alert(isPresented: Binding(get: { deletionError != nil }, set: { _ in deletionError = nil })) {
                Alert(
                    title: Text("Error"),
                    message: Text(deletionError ?? ""),
                    dismissButton: .default(Text("OK"))
                )
            }

            if let error = deletionError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .navigationTitle("Delete Account")
        .navigationBarBackButtonHidden(true) // Hide back button to avoid navigation loops
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Success"),
                message: Text("Your account has been deleted and you have been signed out."),
                dismissButton: .default(Text("OK")) {
                    // Navigate to the OnboardingView after success alert
                    isAuthenticated = false  // Log the user out and redirect
                    // Perform navigation logic here, for example, by presenting a new view
                }
            )
        }
    }
    
    private func deleteAccount() {
        // Log out the user by setting isAuthenticated to false
        isAuthenticated = false  // Log the user out and redirect to OnboardingView
        
        // Remove stored credentials to ensure the user is logged out
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "password")
        UserDefaults.standard.synchronize()

        // Show success alert after account deletion
        showSuccessAlert = true
        
        print("Account deleted and user signed out successfully")
    }
}



