//
//  ProfileView.swift
//  FinanceApp
//
//  Created by Tina  on 17.02.25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all) // White background
                
                VStack(spacing: 20) {
                    Spacer()

                    // Title
                    Text("Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    // Loading indicator or user info
                    if let user = viewModel.user {
                        // User Information
                        VStack(spacing: 15) {
                            Text("Email: \(user.email)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("Bank: \(user.bank)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("Joined: \(user.createdAt.formatted(date: .long, time: .shortened))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            // Email Verification Status
                            if viewModel.isEmailVerified {
                                Text("✅ Email Verified")
                                    .foregroundColor(.green)
                            } else {
                                Text("❌ Email Not Verified")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1))) // Light background for user info
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    } else {
                        // If user data is not yet loaded
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .padding()
                    }

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
            .navigationTitle("Profile")
            .onAppear {
                viewModel.fetchUserData()
            }
        }
    }
}



#Preview {
    ProfileView()
}
