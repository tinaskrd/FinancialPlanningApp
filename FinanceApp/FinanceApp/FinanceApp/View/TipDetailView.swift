//
//  TipDetailView.swift
//  FinanceApp
//
//  Created by Tina  on 14.02.25.
//

import SwiftUI

struct TipDetailView: View {
    let tip: FinancialTip
    
    var body: some View {
        ZStack {
            Color.white // Set background color to white
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 15) {
                // Title
                Text(tip.title)
                    .font(.title)
                    .bold()
                    .foregroundColor(.black) // Change text color to black
                
                // Content
                ScrollView {
                    Text(tip.content)
                        .font(.body)
                        .foregroundColor(.black.opacity(0.9)) // Change text color to black
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1))) // Light gray background
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
                
                Spacer()
            }
            .padding()
        }
    }
}




