import SwiftUI
import Combine     // Required for ObservableObject
import Foundation  // Required for JSONEncoder/Decoder

class ExpenseViewModel: ObservableObject {
    // Main data source
    @Published var transactions: [Transaction] = [] {
        didSet {
            saveData() // Auto-save whenever data changes
        }
    }
    
    // Key for UserDefaults
    private let itemsKey: String = "saved_transactions"
    
    init() {
        loadData()
    }
    
    // MARK: - CRUD Operations
    
    // Add a new transaction to the list
    func addTransaction(title: String, amount: Double, type: TransactionType, category: Category, date: Date) {
        let newTransaction = Transaction(title: title, amount: amount, type: type, category: category, date: date)
        // Insert at the top of the list for recent view
        withAnimation {
            transactions.insert(newTransaction, at: 0)
        }
    }
    
    // Update an existing transaction by id
    func updateTransaction(id: UUID, title: String, amount: Double, type: TransactionType, category: Category, date: Date) {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else { return }
        let updated = Transaction(id: id, title: title, amount: amount, type: type, category: category, date: date)
        withAnimation {
            transactions[index] = updated
        }
    }
    
    // Delete transaction at specific index
    func deleteTransaction(at offsets: IndexSet) {
        withAnimation {
            transactions.remove(atOffsets: offsets)
        }
    }
    
    // MARK: - Calculations
    
    // Calculate total current balance
    var balance: Double {
        let income = transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let expense = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        return income - expense
    }
    
    // MARK: - Data Persistence
    
    // Save data to UserDefaults using JSONEncoder
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: itemsKey)
        }
    }
    
    // Load data from UserDefaults using JSONDecoder
    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: itemsKey),
              let decodedTransactions = try? JSONDecoder().decode([Transaction].self, from: data) else {
            return
        }
        self.transactions = decodedTransactions
    }
    
    // MARK: - Reporting Logic
    
    // Helper to group and sort transactions (Refactored to reuse logic)
    private func groupExpenses(_ filteredTransactions: [Transaction]) -> [CategorySummary] {
        var grouping: [Category: Double] = [:]
        for transaction in filteredTransactions {
            grouping[transaction.category, default: 0] += transaction.amount
        }
        return grouping.map { CategorySummary(category: $0.key, total: $0.value) }
                       .sorted { $0.total > $1.total }
    }
    
    // 1. Monthly Report: Filter by Month & Year
    func getMonthlyCategorySummary(month: Int, year: Int) -> [CategorySummary] {
        let calendar = Calendar.current
        let filtered = transactions.filter { transaction in
            let components = calendar.dateComponents([.month, .year], from: transaction.date)
            return components.month == month && components.year == year && transaction.type == .expense
        }
        return groupExpenses(filtered)
    }
    
    // 2. Yearly Report: Filter by Year only
    func getYearlyCategorySummary(year: Int) -> [CategorySummary] {
        let calendar = Calendar.current
        let filtered = transactions.filter { transaction in
            let components = calendar.dateComponents([.year], from: transaction.date)
            return components.year == year && transaction.type == .expense
        }
        return groupExpenses(filtered)
    }
}

