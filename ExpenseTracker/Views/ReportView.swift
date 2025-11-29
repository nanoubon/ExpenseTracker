import SwiftUI
import Charts // Requires iOS 16.0+

enum ReportType: String, CaseIterable {
    case monthly = "รายเดือน"
    case yearly = "รายปี"
}

struct ReportView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    
    // State for Report Type toggle
    @State private var reportType: ReportType = .monthly
    
    // State for Monthly View
    @State private var selectedDate = Date()
    
    // State for Yearly View (Default to current year)
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    
    // State for showing About view
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 1. Report Type Picker (Segmented Control)
                Picker("ประเภทรายงาน", selection: $reportType) {
                    ForEach(ReportType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 2. Date/Year Selector (Changes based on report type)
                HStack {
                    if reportType == .monthly {
                        // Monthly: Use DatePicker
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            Text("เลือกเดือน:")
                                .font(.headline)
                            DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                                .labelsHidden()
                                .environment(\.locale, Locale(identifier: "th_TH"))
                        }
                    } else {
                        // Yearly: Custom Year Stepper
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.purple)
                            
                            // FIX: Display Thai Year correctly based on system calendar
                            Text("ปี พ.ศ. \(formatThaiYear(year: selectedYear))")
                                .font(.headline)
                            
                            Spacer()
                            
                            HStack(spacing: 20) {
                                Button(action: { selectedYear -= 1 }) {
                                    Image(systemName: "chevron.left.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                }
                                Button(action: { selectedYear += 1 }) {
                                    Image(systemName: "chevron.right.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // 3. Logic to fetch data based on selection
                let summaryData: [CategorySummary] = {
                    if reportType == .monthly {
                        let calendar = Calendar.current
                        let month = calendar.component(.month, from: selectedDate)
                        let year = calendar.component(.year, from: selectedDate)
                        return viewModel.getMonthlyCategorySummary(month: month, year: year)
                    } else {
                        return viewModel.getYearlyCategorySummary(year: selectedYear)
                    }
                }()
                
                let totalExpense = summaryData.reduce(0) { $0 + $1.total }
                
                // 4. Display Content
                if summaryData.isEmpty {
                    Spacer()
                    VStack(spacing: 15) {
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("ไม่มีข้อมูลรายจ่าย")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(reportType == .monthly ? "ในเดือนนี้" : "ในปีนี้")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    List {
                        // Chart Section
                        Section {
                            VStack(alignment: .leading) {
                                Text("รวมทั้งสิ้น: \(totalExpense.thb2)")
                                    .font(.title3.bold())
                                    .padding(.bottom, 15)
                                
                                Chart(summaryData) { item in
                                    BarMark(
                                        x: .value("Category", item.category.rawValue),
                                        y: .value("Amount", item.total)
                                    )
                                    .foregroundStyle(item.category.color)
                                    .annotation(position: .top) {
                                        Text(item.total.thb0)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(height: 220)
                            }
                            .padding(.vertical)
                        } header: {
                            Text("แผนภูมิสรุปผล")
                        }
                        
                        // Breakdown List
                        Section(header: Text("รายละเอียดแยกหมวดหมู่")) {
                            ForEach(summaryData) { item in
                                HStack {
                                    Image(systemName: item.category.icon)
                                        .foregroundColor(.white)
                                        .frame(width: 30, height: 30)
                                        .background(item.category.color)
                                        .clipShape(Circle())
                                    
                                    Text(item.category.rawValue)
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text(item.total.thb2)
                                            .bold()
                                        // Calculate percentage
                                        Text("\(String(format: "%.1f", (item.total / totalExpense) * 100))%")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("สรุปรายจ่าย")
            .navigationBarTitleDisplayMode(.inline)
            // Add Toolbar for About Us
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAbout = true }) {
                        Image(systemName: "info.circle")
                    }
                }
            }
            // Sheet to present AboutView
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
    
    // Helper function to format Thai Year correctly
    func formatThaiYear(year: Int) -> String {
        // If system is already Buddhist (e.g. 2568), return as is
        if Calendar.current.identifier == .buddhist {
            return "\(year)"
        } else {
            // If system is Gregorian (e.g. 2025), add 543
            return "\(year + 543)"
        }
    }
}

// Separate View for "About Us" content
struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "wallet.pass.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .padding(.top, 40)
                
                Text("Expense Tracker")
                    .font(.largeTitle.bold())
                
                Text("เวอร์ชัน 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Divider()
                    .padding(.horizontal, 40)
                
                VStack(spacing: 10) {
                    Text("แอปพลิเคชันบันทึก รายรับ-รายจ่าย")
                        .font(.headline)
                    Text("ช่วยให้คุณจัดการการเงินได้อย่างมีประสิทธิภาพ\nดูสรุปผลได้ทั้งรายเดือนและรายปี")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Text("© 2025 Nano Developers")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
            .navigationTitle("เกี่ยวกับเรา")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("ปิด") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
