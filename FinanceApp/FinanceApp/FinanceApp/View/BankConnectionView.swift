//
//  BankConnectionView.swift
//  FinanceApp
//
//  Created by Tina  on 1.02.25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct BankConnectionView: View {
    @StateObject private var viewModel = BankViewModel()
    @State private var selectedBank: String? // Store the selected bank
    @State private var isBankSaved = false // Flag to track if the bank is saved successfully
    @State private var errorMessage: String? // Store any error messages
    
    // Add a state to handle the fullScreenCover transition
    @State private var navigateToDashboard = false
    
    var body: some View {
        ZStack {
            // White Background
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Title
                Text("Choose Your Bank")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 40)
                
                // Loading indicator
                if viewModel.isLoading {
                    ProgressView() // Show a loading spinner
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    // Error Message
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.top, 10)
                } else {
                    // List of banks
                    List(viewModel.banks) { bank in
                        Text(bank.name)
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                            .background(selectedBank == bank.name ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(12)
                            .onTapGesture {
                                // Update the selected bank when tapped
                                selectedBank = bank.name
                            }
                    }
                    .listStyle(PlainListStyle())
                    .padding(.top, 10)
                }

                // Display a success message if the bank is saved
                if isBankSaved {
                    Text("Bank saved successfully!")
                        .foregroundColor(.green)
                        .font(.subheadline)
                        .padding(.top, 10)
                }
                
                // Display a message if no bank is selected
                if selectedBank == nil {
                    Text("Please select a bank.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .padding(.top, 10)
                }

                Spacer()

                // Save Bank Button
                Button(action: {
                    if let bankName = selectedBank {
                        saveBankToFirestore(bankName: bankName)
                        UserDefaults.standard.set(true, forKey: "isAuthenticated")
                    } else {
                        errorMessage = "Please select a bank first!"
                    }
                }) {
                    Text("Save Bank")
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
                .disabled(selectedBank == nil)  // Disable if no bank is selected

                Spacer(minLength: 40)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(radius: 10)
            )
            .padding()
        }
        .onAppear {
            viewModel.fetchBanks() // Fetch banks from Firestore when the view appears
        }
        // Trigger the fullScreenCover when the bank is saved
        .fullScreenCover(isPresented: $navigateToDashboard) {
            TabUIView() // Dashboard View after successful bank saving
        }
    }
    
    // Function to save the selected bank to Firestore
    private func saveBankToFirestore(bankName: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No authenticated user found")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userID).setData(["bank": bankName], merge: true) { error in
            if let error = error {
                print("Error saving bank: \(error.localizedDescription)")
                self.errorMessage = "Failed to save bank. Please try again."
            } else {
                isBankSaved = true // Update flag if bank is saved successfully
                errorMessage = nil // Reset any previous error message
                navigateToDashboard = true // Trigger the navigation to the DashboardView
            }
        }
    }
}

struct BankConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        BankConnectionView()
            .preferredColorScheme(.light)
    }
}

