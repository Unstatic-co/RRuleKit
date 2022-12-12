//
//  RecurrenceRule+String.swift
//
//
//  Created by Thanh Duy Truong on 09/12/2022.
//

import Foundation

public extension RecurrenceRule {
    var toString: String {
        // TODO: Add missing cases
        if interval == 1 {
            switch frequency {
            case .weekly:
                if daysOfTheWeek.map(\.dayOfTheWeek) == Weekday.allWeekdays {
                    return "\(Localized.every) \(Localized.weekday)"
                }
                if daysOfTheWeek.map(\.dayOfTheWeek) == Weekday.weekendDays {
                    return "\(Localized.every) \(Localized.weekend)"
                }
            default:
                break
            }
            return "\(Localized.every) \(frequency.pluralText(interval))"
        }
        return frequency.everyText(interval)
    }
}
