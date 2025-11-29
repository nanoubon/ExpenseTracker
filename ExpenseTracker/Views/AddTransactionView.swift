import SwiftUI

struct AddTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ExpenseViewModel
    
    // สำหรับโหมดแก้ไข (nil = เพิ่มใหม่)
    private let editingTransaction: Transaction?
    
    // Form States
    @State private var title: String
    @State private var amount: String
    @State private var type: TransactionType
    @State private var category: Category
    @State private var date: Date
    
    // กำหนด init เพื่อเติมค่าจากรายการที่จะแก้ไข
    init(viewModel: ExpenseViewModel, transactionToEdit: Transaction? = nil) {
        self.viewModel = viewModel
        self.editingTransaction = transactionToEdit
        _title = State(initialValue: transactionToEdit?.title ?? "")
        _amount = State(initialValue: transactionToEdit.map { String(format: "%.2f", $0.amount) } ?? "")
        _type = State(initialValue: transactionToEdit?.type ?? .expense)
        _category = State(initialValue: transactionToEdit?.category ?? .food)
        _date = State(initialValue: transactionToEdit?.date ?? Date())
    }
    
    private var isEditing: Bool { editingTransaction != nil }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("รายละเอียด")) {
                    TextField("ชื่อรายการ (เช่น กาแฟ)", text: $title)
                    TextField("จำนวนเงิน", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    // Type Picker (Income/Expense)
                    Picker("ประเภท", selection: $type) {
                        ForEach(TransactionType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("หมวดหมู่")) {
                    // Category Picker with Icons
                    Picker("เลือกหมวดหมู่", selection: $category) {
                        ForEach(Category.allCases) { cat in
                            HStack {
                                Image(systemName: cat.icon)
                                    .foregroundColor(cat.color)
                                Text(cat.rawValue)
                            }.tag(cat)
                        }
                    }
                    DatePicker("วันที่", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle(isEditing ? "แก้ไขรายการ" : "เพิ่มรายการ")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("ยกเลิก") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("บันทึก") {
                        guard let amountDouble = Double(amount), !title.isEmpty else { return }
                        if let tx = editingTransaction {
                            viewModel.updateTransaction(
                                id: tx.id,
                                title: title,
                                amount: amountDouble,
                                type: type,
                                category: category,
                                date: date
                            )
                        } else {
                            viewModel.addTransaction(
                                title: title,
                                amount: amountDouble,
                                type: type,
                                category: category,
                                date: date
                            )
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.isEmpty || amount.isEmpty)
                }
            }
        }
    }
}

