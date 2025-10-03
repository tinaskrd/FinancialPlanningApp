//
//  ReportsView.swift
//  FinanceApp
//
//  Created by Tina  on 17.02.25.
//
import SwiftUI
import Charts

struct ReportsView: View {
    @StateObject private var bankAPI = BankAPI()
    @State private var selectedTimePeriod: String = "Month"
    
    let timePeriods = ["Day", "Week", "Month", "Year"]
    
    // Convert transaction date from String to Date
    func dateObject(from dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Assuming format is YYYY-MM-DD
        return formatter.date(from: dateString)
    }
    
    var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        
        let filtered = bankAPI.transactions.filter { transaction in
            guard let transactionDate = dateObject(from: transaction.date) else { return false }
            
            switch selectedTimePeriod {
            case "Day":
                return calendar.isDateInToday(transactionDate)
            case "Week":
                return calendar.isDate(transactionDate, equalTo: now, toGranularity: .weekOfYear)
            case "Month":
                return calendar.isDate(transactionDate, equalTo: now, toGranularity: .month)
            case "Year":
                return calendar.isDate(transactionDate, equalTo: now, toGranularity: .year)
            default:
                return true
            }
        }
        
        return filtered
    }
    
    var categorizedExpenses: [(category: String, amount: Double)] {
        let expenseCategories = Dictionary(grouping: filteredTransactions.filter { $0.amount < 0 }, by: { $0.description })
        return expenseCategories.map { (key, transactions) in
            (key, transactions.reduce(0) { $0 + abs($1.amount) })
        }
    }
    
    var trendData: [(date: String, income: Double, expenses: Double)] {
        let groupedTransactions = Dictionary(grouping: filteredTransactions, by: { $0.date })
        
        return groupedTransactions.map { (key, transactions) in
            let income = transactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
            let expenses = transactions.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
            return (key, income, expenses)
        }.sorted { $0.date < $1.date }
    }
    
    var totalIncome: Double {
        filteredTransactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpenses: Double {
        filteredTransactions.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount }
    }
    
    var balance: Double {
        totalIncome + totalExpenses
    }
    
    // Calculate the category with the highest expenses
    var highestExpenseCategory: String {
        guard let maxExpense = categorizedExpenses.max(by: { $0.amount < $1.amount }) else {
            return "No expenses recorded"
        }
        return "Attention! The category you spent the most on is \(maxExpense.category), with a total of $\(String(format: "%.2f", maxExpense.amount))."
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Time Period Picker
                    Picker("Time Period", selection: $selectedTimePeriod) {
                        ForEach(timePeriods, id: \.self) { Text($0) }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    // Summary
                    HStack {
                        VStack {
                            Text("Income")
                                .font(.headline)
                            Text(String(format: "$%.2f", totalIncome))
                                .foregroundColor(.green)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Text("Expenses")
                                .font(.headline)
                            Text(String(format: "$%.2f", abs(totalExpenses)))
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Text("Balance")
                                .font(.headline)
                            Text(String(format: "$%.2f", balance))
                                .foregroundColor(balance >= 0 ? .green : .red)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    
                    // Pie Chart for Category Breakdown
                    if #available(iOS 16.0, *) {
                        Chart {
                            ForEach(categorizedExpenses, id: \.category) { data in
                                SectorMark(angle: .value("Amount", data.amount), innerRadius: .ratio(0.5))
                                    .foregroundStyle(by: .value("Category", data.category))
                            }
                        }
                        .frame(height: 300)
                        .padding()
                    }
                    
                    // Dots Chart for Trend Analysis (Replaces Line Chart)
                    if #available(iOS 16.0, *) {
                        Chart {
                            ForEach(trendData, id: \.date) { data in
                                PointMark(
                                    x: .value("Date", data.date),
                                    y: .value("Income", data.income)
                                )
                                .foregroundStyle(.green)
                                
                                PointMark(
                                    x: .value("Date", data.date),
                                    y: .value("Expenses", data.expenses)
                                )
                                .foregroundStyle(.red)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .frame(height: 250)
                        .padding()
                    }
                    
                    // Top Transactions
                    VStack(alignment: .leading) {
                        Text("Top Transactions for \(selectedTimePeriod)")
                            .font(.headline)
                            .padding(.top)
                        
                        if filteredTransactions.isEmpty {
                            Text("No transactions available for this period.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(filteredTransactions.sorted(by: { abs($0.amount) > abs($1.amount) }).prefix(5)) { transaction in
                                VStack(alignment: .leading) {
                                    Text(transaction.description)
                                        .font(.headline)
                                    Text(transaction.date)
                                        .font(.subheadline)
                                    Text(String(format: "$%.2f", transaction.amount))
                                        .font(.subheadline)
                                        .foregroundColor(transaction.amount >= 0 ? .green : .red)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    
                    // Conclusion: Highest Expense Category (Aligned Same as Top Transactions)
                    VStack(alignment: .leading) {
                        
                        Text(highestExpenseCategory)
                            .font(.headline)
                            .padding()
                            .foregroundColor(.red)
                    }
                    .padding()
                }
                .navigationTitle("Reports")
                .onAppear {
                    if bankAPI.transactions.isEmpty {
                        bankAPI.fetchTransactions()
                    }
                }
            }
        }
    }
}

#Preview {
    ReportsView()
}



