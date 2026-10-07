//
//  Date+Formatting.swift
//  Kino
//
//  Created by Marco Maddalena on 23.03.26.
//

import Foundation

extension Date {
    /// Formats date as "23 September 1994" using device locale
    public func toMonthDayYearString() -> String {
        formatted(
            Date.FormatStyle()
                .day()
                .month(.wide)
                .year()
                .locale(Locale.current)
        )
    }

    /// Formats today's date as "yyyy-MM-dd" for API queries
    public nonisolated static func todayAsAPIFormat() -> String {
        Date.now.formatted(
            Date.FormatStyle()
                .year()
                .month()
                .day()
                .locale(Locale(identifier: "en_US_POSIX"))
        )
    }
}

extension String {
    /// Converts ISO 8601 date string to "23 September 1994" format
    public func toMonthDayYearString() -> String? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        guard let date = formatter.date(from: self) else { return nil }
        return date.toMonthDayYearString()
    }

    /// Converts release date string (ISO 8601) to "23 September 1994" format
    public func asFormattedReleaseDate() -> String? {
        guard !self.isEmpty else { return nil }
        return self.toMonthDayYearString()
    }
}
