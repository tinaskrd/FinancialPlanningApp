//
//  ContentView.swift
//  FinanceApp
//
//  Created by Tina  on 1.02.25.
//
import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isPasswordVisible = false
    @State private var showForgotPasswordSheet = false
    
    @AppStorage("isAuthenticated") private var isAuthenticated = false

    var body: some View {
        if isAuthenticated {
            TabUIView()
        } else {
            NavigationStack {
                ZStack {
                    // White Background
                    Color.white
                        .edgesIgnoringSafeArea(.all)

                    VStack(spacing: 20) {
                        Spacer()

                        // Logo or Illustration
                        Image("bankTwo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding(.bottom, 10)

                        // Welcome Title
                        Text("Welcome Back!")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)

                        Text("Log in to continue")
                            .foregroundColor(.gray)
                            .padding(.bottom, 20)

                        // Input Fields
                        VStack(spacing: 16) {
                            CustomTextInput(title: "Email", text: $email, placeholder: "Enter your email", keyboardType: .emailAddress)
                            CustomPasswordInput(title: "Password", text: $password, isPasswordVisible: $isPasswordVisible)
                        }
                        .padding(.horizontal)

                        // Error & Success Messages
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

                        // Login Button
                        Button(action: {
                            viewModel.login(email: email, password: password) { error in
                                if let error = error {
                                    self.errorMessage = error.localizedDescription
                                    self.successMessage = nil
                                } else {
                                    isAuthenticated = true
                                    UserDefaults.standard.set(email, forKey: "email")
                                    UserDefaults.standard.set(password, forKey: "password")
                                }
                            }
                        }) {
                            Text("Login")
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
                        .padding(.horizontal)

                        // Forgot Password
                        Button("Forgot Password?") {
                            showForgotPasswordSheet = true
                        }
                        .foregroundColor(.blue)
                        .padding(.top, 5)
                        .sheet(isPresented: $showForgotPasswordSheet) {
                            ForgotPasswordSheet(viewModel: viewModel)
                        }

                        Spacer()

                        // Registration Link
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.gray)

                            NavigationLink(destination: RegistrationView()) {
                                Text("Register")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.bottom, 20)
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
    }
}

// MARK: - Custom Text Input
struct CustomTextInput: View {
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

// MARK: - Custom Password Input
struct CustomPasswordInput: View {
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
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .preferredColorScheme(.light)
    }
}

