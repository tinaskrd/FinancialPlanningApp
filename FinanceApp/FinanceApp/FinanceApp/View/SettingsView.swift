//  SettingsView.swift
//  FinanceApp
//
//  Created by Tina  on 1.02.25.
//

// added comment

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var isEmailVerified = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showDeleteProfileModal = false
    @State private var showChangePasswordModal = false
    @State private var showChangeEmailModal = false
    @State private var showPrivacyPolicyModal = false

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    // Account Section
                    Section(header: Text("Account").foregroundColor(.gray)) {
                        Button(action: { showChangePasswordModal.toggle() }) {
                            Label("Change Password", systemImage: "lock.fill")
                                .foregroundColor(.black)
                        }
                        
                        Button(action: { showDeleteProfileModal.toggle() }) {
                            Label("Delete My Profile", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    
                    // ✅ Verify Email Section
                    Section(header: Text("Email Verification").foregroundColor(.gray)) {
                        HStack {
                            Label("Email Status", systemImage: isEmailVerified ? "checkmark.seal.fill" : "xmark.seal.fill")
                                .foregroundColor(isEmailVerified ? .green : .red)
                            Spacer()
                            Text(isEmailVerified ? "Verified" : "Not Verified")
                                .foregroundColor(isEmailVerified ? .green : .red)
                        }
                        
                        if !isEmailVerified {
                            Button(action: sendVerificationEmail) {
                                Label("Resend Verification Email", systemImage: "paperplane.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }

                    // Legal Section
                    Section(header: Text("Legal").foregroundColor(.gray)) {
                        Button(action: { showPrivacyPolicyModal.toggle() }) {
                            Label("Privacy Policy & Terms", systemImage: "doc.text.fill")
                                .foregroundColor(.black)
                        }
                    }
                }
                .navigationTitle("Settings")
                .onAppear {
                    checkEmailVerificationStatus()
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Email Verification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
        .sheet(isPresented: $showDeleteProfileModal) {
            DeleteAccountView()
        }
        .sheet(isPresented: $showChangePasswordModal) {
            ChangePasswordView()
        }
        .sheet(isPresented: $showChangeEmailModal) {
            ChangeEmailView()
        }
        .sheet(isPresented: $showPrivacyPolicyModal) {
            PrivacyPolicyView()
        }
    }

    // Function to check if email is verified
    private func checkEmailVerificationStatus() {
        if let user = Auth.auth().currentUser {
            user.reload { error in
                if error == nil {
                    isEmailVerified = user.isEmailVerified
                }
            }
        }
    }

    // Function to resend verification email
    private func sendVerificationEmail() {
        if let user = Auth.auth().currentUser {
            user.sendEmailVerification { error in
                if let error = error {
                    alertMessage = "Error sending email: \(error.localizedDescription)"
                } else {
                    alertMessage = "A verification email has been sent. Please check your inbox."
                }
                showAlert = true
            }
        }
    }
}
