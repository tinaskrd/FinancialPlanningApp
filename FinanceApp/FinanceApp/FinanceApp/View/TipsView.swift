//
//  TipsView.swift
//  FinanceApp
//
//  Created by Tina  on 1.02.25.
//

import SwiftUI
import Firebase
import FirebaseDatabase

struct TipsView: View {
    @StateObject private var viewModel = TipsViewModel()
    @State private var selectedTip: FinancialTip?
    @State private var showDetailView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white // Set background color to white
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Financial Tips")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black) // Change text color to black
                        .padding(.top, 40)
                    
                    List(viewModel.tips) { tip in
                        CustomTipRow(title: tip.title)
                            .onTapGesture {
                                selectedTip = tip
                                showDetailView = true
                            }
                            .listRowBackground(Color.white.opacity(0.0))
                    }
                    .listStyle(InsetGroupedListStyle())
                    .padding(.top, 10)
                }
                .padding()
            }
            .onAppear {
                viewModel.fetchTips()
            }
            .sheet(item: $selectedTip) { tip in
                TipDetailView(tip: tip)
            }
        }
    }
}

// MARK: - Custom Tip Row
struct CustomTipRow: View {
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
                .padding(.trailing, 10)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .bold()
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.7)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
        .shadow(radius: 3)
    }
}



