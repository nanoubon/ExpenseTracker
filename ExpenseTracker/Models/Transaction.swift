import SwiftUI

// MARK: - Enums

// Transaction Type Enum (Conforms to Codable for saving)
enum TransactionType: String, CaseIterable, Identifiable, Codable {
    case income = "รายรับ"
    case expense = "รายจ่าย"
    var id: String { self.rawValue }
}

// Category Enum with Icons & Colors
enum Category: String, CaseIterable, Identifiable, Codable {
    case salary = "เงินเดือน"
    case food = "อาหาร"
    case transport = "เดินทาง"
    case shopping = "ช้อปปิ้ง"
    case bills = "บิล/ค่าน้ำไฟ"
    case entertainment = "บันเทิง"
    case other = "อื่นๆ"
    
    var id: String { self.rawValue }
    
    // SF Symbols icon name for each category
    var icon: String {
        switch self {
        case .salary: return "dollarsign.circle.fill"
        case .food: return "fork.knife.circle.fill"
        case .transport: return "car.circle.fill"
        case .shopping: return "bag.circle.fill"
        case .bills: return "bolt.circle.fill"
        case .entertainment: return "tv.circle.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
    
    // Color associated with each category
    var color: Color {
        switch self {
        case .salary: return .green
        case .food: return .orange
        case .transport: return .blue
        case .shopping: return .pink
        case .bills: return .purple
        case .entertainment: return .indigo
        case .other: return .gray
        }
    }
}

// MARK: - Data Structures

// Main Transaction Model
struct Transaction: Identifiable, Codable {
    var id = UUID()
    let title: String
    let amount: Double
    let type: TransactionType
    let category: Category
    let date: Date
}

// Helper struct for Chart Data aggregation
struct CategorySummary: Identifiable {
    let id = UUID()
    let category: Category
    let total: Double
}
