//
//  Int+Formatting.swift
//  Kino
//
//  Created by Marco Maddalena on 24.03.26.
//

import Foundation

extension Int {
    /// Formats runtime in minutes as human-readable duration (e.g., "2h 14m" or "98m")
    public func asFormattedRuntime() -> String? {
        guard self > 0 else { return nil }
        let hours = self / 60
        let minutes = self % 60
        return hours > 0
            ? String(localized: "common.runtime.hoursMinutes \(hours) \(minutes)", bundle: .module)
            : String(localized: "common.runtime.minutesOnly \(minutes)", bundle: .module)
    }

    /// Formats integer as USD currency (e.g., "$100,000,000")
    public func asFormattedCurrency() -> String? {
        guard self > 0 else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: self)) ?? "$\(self)"
    }
}
