//
//  RecurrenceFrequency+String.swift
//
//
//  Created by Thanh Duy Truong on 09/12/2022.
//

public extension RecurrenceFrequency {
    var text: String {
        switch self {
        case .minutely:
            return Localized.minutely
        case .hourly:
            return Localized.hourly
        case .daily:
            return Localized.daily
        case .weekly:
            return Localized.weekly
        case .monthly:
            return Localized.monthly
        case .yearly:
            return Localized.yearly
        }
    }

    func pluralText(_ value: Int) -> String {
        switch self {
        case .minutely:
            return Localized.minutes(value)
        case .hourly:
            return Localized.hours(value)
        case .daily:
            return Localized.days(value)
        case .weekly:
            return Localized.weeks(value)
        case .monthly:
            return Localized.months(value)
        case .yearly:
            return Localized.years(value)
        }
    }

    func everyText(_ value: Int) -> String {
        switch self {
        case .minutely:
            return Localized.everyMinutes(value)
        case .hourly:
            return Localized.everyHours(value)
        case .daily:
            return Localized.everyDays(value)
        case .weekly:
            return Localized.everyWeeks(value)
        case .monthly:
            return Localized.everyMonths(value)
        case .yearly:
            return Localized.everyYears(value)
        }
    }
}
