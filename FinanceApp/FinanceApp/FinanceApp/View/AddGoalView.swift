//
//  AddNewGoalView.swift
//  FinanceApp
//
//  Created by Tina  on 17.02.25.
//

import SwiftUI

struct AddGoalView: View {
    let categories: [String]
    @Binding var selectedCategory: String
    @Binding var newGoalAmount: String
    var addGoal: () -> Void  // Closure to add goal
    
    @Environment(\.presentationMode) var presentationMode
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // Background Color
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                
                // Heading
                Text("Set a Spending Goal")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.bottom, 10)
                
                // Category Picker
                VStack(spacing: 16) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    
                    TextField("Goal Amount ($)", text: $newGoalAmount)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                        .foregroundColor(.black)
                }
                .padding(.horizontal)

                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.top, 5)
                }

                // Save Goal Button
                Button(action: {
                    if newGoalAmount.isEmpty {
                        self.errorMessage = "Please enter a valid goal amount."
                    } else {
                        self.errorMessage = nil
                        addGoal()
                        presentationMode.wrappedValue.dismiss()  // Close sheet
                    }
                }) {
                    Text("Save Goal")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                                                   startPoint: .leading,
                                                   endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)

                Spacer()
                
                // Cancel Button
                HStack {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)
                    .font(.body)
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

