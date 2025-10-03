//
//  PrivacyPolicyView.swift
//  FinanceApp
//
//  Created by Tina  on 24.03.25.
//

import SwiftUI
import FirebaseFirestore

struct PrivacyPolicyView: View {
    @State private var privacyPolicyText: String = "Loading..."

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image("privacyIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.bottom, 10)
                    
                    Text("Privacy Policy & Terms")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    ScrollView {
                        Text(privacyPolicyText)
                            .font(.body)
                            .foregroundColor(.gray)
                            .padding()
                    }
                    .frame(maxHeight: 300)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
                    .padding(.horizontal)
                    
                    Text("By using this app, you agree to our Terms and Privacy Policy.")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding()
                    
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
            .onAppear(perform: fetchPrivacyPolicy)
        }
    }

    private func fetchPrivacyPolicy() {
        let db = Firestore.firestore()
        db.collection("appInfo").document("privacyPolicy").getDocument { document, error in
            if let error = error {
                privacyPolicyText = "Error: \(error.localizedDescription)"
                return
            }

            if let document = document, document.exists, let text = document.data()? ["privacyPolicy"] as? String {
                privacyPolicyText = text
            } else {
                privacyPolicyText = "Error: Privacy policy not found."
            }
        }
    }
}
