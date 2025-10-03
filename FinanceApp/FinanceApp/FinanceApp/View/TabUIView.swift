//
//  TabUIView.swift
//  FinanceApp
//
//  Created by Tina  on 17.02.25.
//

import SwiftUI

struct TabUIView: View {
    var body: some View {
        TabView {
                    DashboardView()
                        .tabItem {
                            Label("Dashboard", systemImage: "chart.bar.fill")
                        }
                    
                    FinancialPlanningView()
                        .tabItem {
                            Label("Plan", systemImage: "list.bullet")
                        }
                    
                    OtherView()
                        .tabItem {
                            Label("Other", systemImage: "ellipsis")
                        }
                }
    }
}

#Preview {
    TabUIView()
}
