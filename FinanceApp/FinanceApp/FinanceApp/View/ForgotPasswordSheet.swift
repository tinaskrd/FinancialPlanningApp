//
//  ForgotPasswordSheet.swift
//  FinanceApp
//
//  Created by Tina  on 18.03.25.
//

import SwiftUI

struct ForgotPasswordSheet: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @Environment(\.dismiss) var dismiss  // To close the sheet

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image("emailIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.bottom, 10)
                    
                    Text("Reset Password")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        
                    Text("Enter your email and we'll send you a link to reset your password.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    TextField("Enter your email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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
                    
                    Button(action: sendResetEmail) {
                        Text("Send Reset Email")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                    
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    .padding(.top, 10)
                    
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
    
    private func sendResetEmail() {
        viewModel.sendPasswordReset(email: email) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.successMessage = nil
            } else {
                self.successMessage = "Password reset email sent!"
                self.errorMessage = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    dismiss()
                }
            }
        }
    }
}
