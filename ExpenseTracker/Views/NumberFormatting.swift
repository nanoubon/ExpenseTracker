// NumberFormatting.swift
import Foundation

private extension NumberFormatter {
    static let decimal0: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.decimalSeparator = "."
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 0
        return f
    }()
    
    static let decimal2: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.decimalSeparator = "."
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()
}

extension Double {
    func formattedWithSeparator(fractionDigits: Int) -> String {
        let formatter: NumberFormatter
        switch fractionDigits {
        case 0: formatter = .decimal0
        case 2: formatter = .decimal2
        default:
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.groupingSeparator = ","
            f.decimalSeparator = "."
            f.minimumFractionDigits = fractionDigits
            f.maximumFractionDigits = fractionDigits
            formatter = f
        }
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }
    
    var thb2: String { "฿" + formattedWithSeparator(fractionDigits: 2) }
    var thb0: String { "฿" + formattedWithSeparator(fractionDigits: 0) }
}

extension Int {
    var withSeparator: String {
        NumberFormatter.decimal0.string(from: NSNumber(value: self)) ?? String(self)
    }
    var thb: String { "฿" + withSeparator }
}
