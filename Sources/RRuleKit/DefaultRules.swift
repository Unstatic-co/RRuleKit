//
//  DefaultRules.swift
//
//
//  Created by Thanh Duy Truong on 02/12/2022.
//

public extension RecurrenceRule {
    static let everyDay: RecurrenceRule = .init(recurrenceWith: .daily)!
    static let everyWeekDay: RecurrenceRule = .init(
        recurrenceWith: .weekly,
        daysOfTheWeek: Weekday.allWeekdays.map { .init($0) }
    )!
    static let everyWeekend: RecurrenceRule = .init(
        recurrenceWith: .weekly,
        daysOfTheWeek: Weekday.weekendDays.map { .init($0) }
    )!
    static let everyHour: RecurrenceRule = .init(
        recurrenceWith: .hourly
    )!
    static let every15Mins: RecurrenceRule = .init(
        recurrenceWith: .minutely,
        interval: 15
    )!
}
