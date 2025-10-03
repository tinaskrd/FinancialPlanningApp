//
//  RegistrationView.swift
//  FinanceApp
//
//  Created by Tina  on 1.02.25.
//

import SwiftUI

struct RegistrationView: View {
    @Environment(\.dismiss) var dismiss // Allows dismissing this view
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isPasswordVisible = false
    @StateObject private var viewModel = AuthViewModel()
    @State private var navigateToBankConnection = false
    @State private var shouldNavigateToBankConnection = false

    var body: some View {
        ZStack {
            // White Background
            Color.white
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Logo or Illustration
                Image("bankOne")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.bottom, 10)

                // Title
                Text("Create Account")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.bottom, 40)

                // Email Field
                CustomEmailInput(title: "Email", text: $email, placeholder: "Enter your email", keyboardType: .emailAddress)

                // Password Field
                CustomPasswordField(title: "Password", text: $password, isPasswordVisible: $isPasswordVisible)

                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.bottom, 20)
                }

                // Register Button
                Button(action: {
                    viewModel.register(email: email, password: password) { error in
                        if let error = error {
                            self.errorMessage = error.localizedDescription
                        } else {
                            DispatchQueue.main.async {
                                shouldNavigateToBankConnection = true
                            }
                        }
                    }
                }) {
                    Text("Register")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                                                   startPoint: .leading,
                                                   endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.vertical, 10)

                // Login Redirection
                HStack {
                    Text("Already have an account?")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Button(action: {
                        dismiss() // Navigates back to OnboardingView
                    }) {
                        Text("Login")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .bold()
                    }
                }
                .padding(.top, 10)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(radius: 10)
            )
            .padding()
        }
        .navigationBarBackButtonHidden(true) // Hides back button
        .onChange(of: shouldNavigateToBankConnection) { newValue in
            if newValue {
                DispatchQueue.main.async {
                    navigateToBankConnection = true
                }
            }
        }
        .fullScreenCover(isPresented: $navigateToBankConnection) {
            BankConnectionView()
        }
    }
}

// MARK: - Custom Email Input
struct CustomEmailInput: View {
    let title: String
    @Binding var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)

            TextField(placeholder, text: $text)
                .autocapitalization(.none)
                .keyboardType(keyboardType)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                .foregroundColor(.black)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
        }
        .padding(.bottom, 15)
    }
}

// MARK: - Custom Password Field
struct CustomPasswordField: View {
    let title: String
    @Binding var text: String
    @Binding var isPasswordVisible: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)

            HStack {
                if isPasswordVisible {
                    TextField("Enter your password", text: $text)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                        .foregroundColor(.black)
                } else {
                    SecureField("Enter your password", text: $text)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                        .foregroundColor(.black)
                }

                Button(action: { isPasswordVisible.toggle() }) {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
        }
        .padding(.bottom, 15)
    }
}

// MARK: - Preview
struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RegistrationView()
        }
        .preferredColorScheme(.light)
    }
}


