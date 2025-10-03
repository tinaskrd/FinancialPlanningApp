//
//  FinanceAppApp.swift
//  FinanceApp
//
//  Created by Tina  on 1.02.25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct FinanceAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var bankAPI = BankAPI()
    
    var body: some Scene {
        WindowGroup {
            OnboardingView()
            .environmentObject(bankAPI)
        }
    }
}
