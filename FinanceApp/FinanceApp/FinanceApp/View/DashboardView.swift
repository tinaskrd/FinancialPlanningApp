import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var bankAPI = BankAPI()
    @State private var selectedTimePeriod: String = "Month" // Default to 'Month'
    
    let timePeriods = ["Day", "Week", "Month", "Year"]
    
    // Convert transaction date from String to Date
    func dateObject(from dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Assuming format is YYYY-MM-DD
        return formatter.date(from: dateString)
    }
    
    // Filter transactions based on the selected time period
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
        
        // Debugging: print the filtered transactions
        print("Filtered transactions for \(selectedTimePeriod): \(filtered.map { $0.description })")
        
        return filtered
    }
    
    // Group transactions into Income and Expenses
    var groupedData: [(category: String, amount: Double)] {
        let income = filteredTransactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
        let expenses = filteredTransactions.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
        
        // Debugging: print the grouped data
        print("Grouped data for \(selectedTimePeriod): Income = \(income), Expenses = \(expenses)")
        
        return [("Income", income), ("Expenses", expenses)]
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Time Period Picker
                Picker("Time Period", selection: $selectedTimePeriod) {
                    ForEach(timePeriods, id: \.self) { period in
                        Text(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Summary of Income and Expenses
                HStack {
                    VStack {
                        Text("Income")
                            .font(.headline)
                        Text(String(format: "$%.2f", groupedData.first { $0.category == "Income" }?.amount ?? 0))
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text("Expenses")
                            .font(.headline)
                        Text(String(format: "$%.2f", abs(groupedData.first { $0.category == "Expenses" }?.amount ?? 0)))
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                
                // Bar chart for Income and Expenses
                if #available(iOS 16.0, *) {
                    Chart {
                        ForEach(groupedData, id: \.category) { data in
                            BarMark(
                                x: .value("Category", data.category),
                                y: .value("Amount", data.amount)
                            )
                            .foregroundStyle(data.category == "Income" ? .green : .red)
                        }
                    }
                    .frame(height: 200)
                    .padding()
                }
                
                // List of filtered transactions
                List(filteredTransactions) { transaction in
                    VStack(alignment: .leading) {
                        Text(transaction.description)
                            .font(.headline)
                        Text(transaction.date)
                            .font(.subheadline)
                        Text(String(format: "$%.2f", transaction.amount))
                            .font(.subheadline)
                            .foregroundColor(transaction.amount >= 0 ? .green : .red)
                    }
                }
            }
            .navigationTitle("Dashboard")
            .onAppear {
                // Fetch transactions when the view appears
                if bankAPI.transactions.isEmpty {
                    bankAPI.fetchTransactions()
                }
                
                // Debugging: Print all transactions to see if the data is correct
                print("All transactions: \(bankAPI.transactions.map { $0.description })")
            }
        }
    }
}


#Preview {
    DashboardView()
}




