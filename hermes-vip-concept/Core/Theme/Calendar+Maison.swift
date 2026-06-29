//
//  Calendar+Maison.swift
//  hermes-vip-concept
//
//

import Foundation

extension Locale {
    /// The maison's locale: French (France).
    static let maison = Locale(identifier: "fr_FR")
}

extension Calendar {
    /// Gregorian calendar, French locale, weeks starting Monday.
    static let maison: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = .maison
        calendar.firstWeekday = 2 // Monday
        return calendar
    }()

    /// The day cells for `month`, padded with leading `nil`s so the first real
    /// day lands under its weekday column (Monday-first).
    func monthGrid(for month: Date) -> [Date?] {
        guard let interval = dateInterval(of: .month, for: month),
              let dayCount = range(of: .day, in: .month, for: month)?.count else {
            return []
        }
        let weekday = component(.weekday, from: interval.start)
        let leading = (weekday - firstWeekday + 7) % 7
        var cells: [Date?] = Array(repeating: nil, count: leading)
        for offset in 0..<dayCount {
            cells.append(date(byAdding: .day, value: offset, to: interval.start))
        }
        return cells
    }
}
