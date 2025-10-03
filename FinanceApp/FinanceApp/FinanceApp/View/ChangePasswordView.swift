//
//  ChangePasswordView.swift
//  FinanceApp
//
//  Created by Tina  on 20.03.25.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var authViewModel = AuthViewModel()

    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isPasswordVisible = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image("lockIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.bottom, 10)
                    
                    Text("Change Password")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        
                    Text("Update your password securely")
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                    
                    VStack(spacing: 16) {
                        CustomPasswordInput(title: "Current Password", text: $currentPassword, isPasswordVisible: $isPasswordVisible)
                        CustomPasswordInput(title: "New Password", text: $newPassword, isPasswordVisible: $isPasswordVisible)
                        CustomPasswordInput(title: "Confirm Password", text: $confirmPassword, isPasswordVisible: $isPasswordVisible)
                    }
                    .padding(.horizontal)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.top, 5)
                    }
                    
                    if let successMessage = successMessage {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .font(.subheadline)
                            .padding(.top, 5)
                    }
                    
                    Button(action: changePassword) {
                        Text("Update Password")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(radius: 10)
                )
                .padding()
            }
        }
    }
    
    private func changePassword() {
        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        authViewModel.changePassword(currentPassword: currentPassword, newPassword: newPassword) { result in
            switch result {
            case .success:
                successMessage = "Password successfully updated"
                errorMessage = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    presentationMode.wrappedValue.dismiss()
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
                successMessage = nil
            }
        }
    }
}

