//
//  OtherView.swift
//  FinanceApp
//
//  Created by Tina  on 17.02.25.
//

import SwiftUI
import FirebaseAuth

struct OtherView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Color
                Color.white
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Title
                    Text("More Options")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 40)

                    Spacer()

                    // Card-like Section
                    VStack(spacing: 16) {
                        NavigationLink(destination: ProfileView()) {
                            CustomListRow(title: "My Profile", systemImage: "person.circle")
                        }
                        
                        NavigationLink(destination: SettingsView()) {
                            CustomListRow(title: "Settings", systemImage: "gearshape")
                        }
                        
                        NavigationLink(destination: ReportsView()) {
                            CustomListRow(title: "Reports", systemImage: "doc.text.magnifyingglass")
                        }

                        NavigationLink(destination: NotesView()) {
                            CustomListRow(title: "My Notes", systemImage: "note.text")
                        }

                        NavigationLink(destination: TipsView()) {
                            CustomListRow(title: "Financial Tips", systemImage: "lightbulb.fill")
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(radius: 10)
                    )
                    .padding()

                    Spacer()

                    // Sign Out Button
                    Button(action: signOut) {
                        Text("Sign Out")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]),
                                                       startPoint: .leading,
                                                       endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
    }

    // Sign Out Function
    private func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            UserDefaults.standard.removeObject(forKey: "email")
            UserDefaults.standard.removeObject(forKey: "password")
            UserDefaults.standard.synchronize()
            print("User signed out successfully")
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

// MARK: - Custom List Row
struct CustomListRow: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}


#Preview {
    OtherView()
}
