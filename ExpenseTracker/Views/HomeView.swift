import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var showingAddModal = false
    @State private var editingTransaction: Transaction? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                VStack {
                    // Balance Card View
                    VStack(spacing: 8) {
                        Text("ยอดเงินคงเหลือ")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        Text(viewModel.balance.thb2)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(25)
                    .background(
                        LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.top)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    // Transaction List
                    List {
                        Section(header: Text("รายการล่าสุด")) {
                            if viewModel.transactions.isEmpty {
                                Text("ยังไม่มีรายการบันทึก")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(viewModel.transactions) { transaction in
                                    TransactionRow(transaction: transaction)
                                        .contentShape(Rectangle()) // ให้แตะได้ทั้งแถว
                                        .onTapGesture {
                                            editingTransaction = transaction
                                        }
                                }
                                .onDelete(perform: viewModel.deleteTransaction)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("กระเป๋าตังค์")
            .toolbar {
                // Add Button
                Button(action: { showingAddModal = true }) {
                    Image(systemName: "plus")
                        .font(.body.weight(.bold))
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            // เพิ่มรายการใหม่
            .sheet(isPresented: $showingAddModal) {
                AddTransactionView(viewModel: viewModel)
            }
            // แก้ไขรายการเดิม
            .sheet(item: $editingTransaction) { transaction in
                AddTransactionView(viewModel: viewModel, transactionToEdit: transaction)
            }
        }
    }
}

// Sub-component for displaying a single transaction row
struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            // Icon
            Image(systemName: transaction.category.icon)
                .foregroundColor(.white)
                .frame(width: 35, height: 35)
                .background(transaction.category.color)
                .clipShape(Circle())
            
            // Title and Date
            VStack(alignment: .leading) {
                Text(transaction.title)
                    .font(.body)
                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Amount with color coding (+/- และคอมมา)
            Text((transaction.type == .income ? "+" : "-") + transaction.amount.formattedWithSeparator(fractionDigits: 0))
                .font(.callout.bold())
                .foregroundColor(transaction.type == .income ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}
