//
//  FinancialPlanningView.swift
//  FinanceApp
//
//  Created by Tina on 17.02.25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import UserNotifications

struct FinancialPlanningView: View {
    @State private var spendingGoals: [SpendingGoal] = []
    @State private var selectedCategory: String = "Grocery Store"
    @State private var newGoalAmount: String = ""
    @State private var isAddingGoal: Bool = false  // Controls sheet presentation

    @StateObject private var categoriesAPI = CategoriesAPI()
    @StateObject private var bankAPI = BankAPI()

    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(spendingGoals.indices, id: \.self) { index in
                        let goal = spendingGoals[index]
                        let spentAmount = calculateSpentAmount(for: goal.category)
                        let remainingAmount = max(goal.goalAmount - spentAmount, 0)

                        VStack(alignment: .leading) {
                            Text(goal.category)
                                .font(.headline)

                            ProgressView(value: spentAmount, total: goal.goalAmount)
                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                .padding(.vertical, 4)

                            HStack {
                                Text("Spent: $\(spentAmount, specifier: "%.2f")")
                                    .foregroundColor(.red)
                                Spacer()
                                Text("Remaining: $\(remainingAmount, specifier: "%.2f")")
                                    .foregroundColor(.green)
                            }
                            .font(.subheadline)
                        }
                        .padding(.vertical, 8)
                    }
                    .onDelete(perform: deleteGoal) // Swipe to delete
                }
                .listStyle(InsetGroupedListStyle())
                .padding(.horizontal)

                Spacer()

                // Add Goal Button
                Button(action: { isAddingGoal.toggle() }) {
                    Text("Add New Goal")
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
                .padding(.bottom, 20)
            }
            .navigationTitle("Financial Planning")
            .onAppear {
                requestNotificationPermission()
                loadGoals()
                categoriesAPI.fetchCategories()

                if bankAPI.transactions.isEmpty {
                    bankAPI.fetchTransactions()  // ✅ Fetch transactions only once
                }
            }
            .sheet(isPresented: $isAddingGoal) {
                AddGoalView(
                    categories: categoriesAPI.categories,
                    selectedCategory: $selectedCategory,
                    newGoalAmount: $newGoalAmount,
                    addGoal: addNewGoal
                )
            }
        }
    }

    // MARK: - Add New Goal and Save to Firestore
    private func addNewGoal() {
        guard let userId = Auth.auth().currentUser?.uid,
              let goalAmount = Double(newGoalAmount),
              !selectedCategory.isEmpty else { return }

        let newGoal = SpendingGoal(userId: userId, category: selectedCategory, goalAmount: goalAmount)

        do {
            try db.collection("spending_goals").document(newGoal.id!).setData(from: newGoal)
            spendingGoals.append(newGoal)
            newGoalAmount = ""
            isAddingGoal = false  // Close the sheet
        } catch {
            print("Error saving goal: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete Goal from Firestore
    private func deleteGoal(at offsets: IndexSet) {
        for index in offsets {
            let goal = spendingGoals[index]

            db.collection("spending_goals").document(goal.id!).delete { error in
                if let error = error {
                    print("Error deleting goal: \(error.localizedDescription)")
                    return
                }

                spendingGoals.remove(atOffsets: offsets)
            }
        }
    }

    // MARK: - Fetch User Goals from Firestore
    private func loadGoals() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("spending_goals")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching goals: \(error.localizedDescription)")
                    return
                }

                if let snapshot = snapshot {
                    self.spendingGoals = snapshot.documents.compactMap { document in
                        try? document.data(as: SpendingGoal.self)
                    }
                }
            }
    }

    // MARK: - Calculate Spent Amount & Trigger Notifications
    private func calculateSpentAmount(for category: String) -> Double {
        let spentAmount = bankAPI.transactions
            .filter { $0.description == category }
            .map { abs($0.amount) }
            .reduce(0, +)

        if let goal = spendingGoals.first(where: { $0.category == category }) {
            if spentAmount >= goal.goalAmount {
                sendNotification(title: "🎉 Goal Reached!", body: "You've met your \(category) spending goal!")
            }
            if spentAmount > goal.goalAmount {
                sendNotification(title: "⚠️ Overspending Alert!", body: "You've overspent your \(category) budget!")
            }
        }

        return spentAmount
    }

    // MARK: - Request Notification Permission
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Send Local Notification
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
}







