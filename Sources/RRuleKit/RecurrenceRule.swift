//
//  RecurrenceRule.swift
//  RRuleKit
//
//  Created by Richard W Maddy on 5/13/18.
//  Copyright © 2018 Maddysoft. All rights reserved.
//

import Foundation

/// Defines frequencies for recurrence rules.
///
/// - daily: Indicates a daily recurrence rule.
/// - weekly: Indicates a weekly recurrence rule.
/// - monthly: Indicates a monthly recurrence rule.
/// - yearly: Indicates a yearly recurrence rule.
public enum RecurrenceFrequency: CaseIterable, Hashable {
    case minutely
    case hourly
    case daily
    case weekly
    case monthly
    case yearly
}

/// The RecurrenceEnd struct defines the end of a recurrence rule defined by an RecurrenceRule object.
/// The recurrence end can be specified by a date (date-based) or by a maximum count of occurrences (count-based).
/// An event which is set to never end should have its RecurrenceEnd set to nil.
public enum RecurrenceEnd: Hashable {
    case end(Date)
    case occurrenceCount(Int)
}

public enum Weekday: Int, CaseIterable, Hashable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    static var allWeekdays: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday]

    static var weekendDays: [Weekday] = [.saturday, .sunday]
}

/// The `RecurrenceDayOfWeek` struct represents a day of the week for use with an `RecurrenceRule` object.
/// A day of the week can optionally have a week number, indicating a specific day in the recurrence rule’s frequency.
/// For example, a day of the week with a day value of `Tuesday` and a week number of `2` would represent the second
/// Tuesday of every month in a monthly recurrence rule, and the second Tuesday of every year in a yearly recurrence
/// rule. A day of the week with a week number of `0` ignores its week number.
public struct RecurrenceDayOfWeek: Hashable {
    /// The day of the week.
    public let dayOfTheWeek: Weekday
    /// The week number of the day of the week.
    ///
    /// Values range from `-53` to `53`. A negative value indicates a value from the end of the range. `0` indicates the week number is irrelevant.
    public let weekNumber: Int

    /// Initializes and returns a day of the week with a given day and week number.
    ///
    /// - Parameters:
    ///   - dayOfTheWeek: The day of the week.
    ///   - weekNumber: The week number.
    public init(dayOfTheWeek: Weekday, weekNumber: Int = 0) {
        self.dayOfTheWeek = dayOfTheWeek
        if weekNumber < -53 || weekNumber > 53 {
            fatalError("weekNumber must be -53 to 53")
        } else {
            self.weekNumber = weekNumber
        }
    }

    public init(_ dayOfTheWeek: Weekday, weekNumber: Int = 0) {
        self.init(dayOfTheWeek: dayOfTheWeek, weekNumber: weekNumber)
    }
}

// TODO: - Use Set instead of Array
/// The `RecurrenceRule` class is used to describe the recurrence pattern for a recurring event.
public struct RecurrenceRule: Hashable {
    /// The frequency of the recurrence rule.
    public var frequency: RecurrenceFrequency
    /// Specifies how often the recurrence rule repeats over the unit of time indicated by its frequency. For example, a recurrence rule with a frequency type of `.weekly` and an interval of `2` repeats every two weeks.
    public var interval: Int
    /// Indicates which day of the week the recurrence rule treats as the first day of the week. No value indicates that this property is not set for the recurrence rule.
    public let firstDayOfTheWeek: Weekday?
    /// The days of the week associated with the recurrence rule, as an array of `RecurrenceDayOfWeek` objects.
    public var daysOfTheWeek: [RecurrenceDayOfWeek]
    /// The days of the month associated with the recurrence rule, as an array of `Int`. Values can be from 1 to 31 and from -1 to -31. This property value is invalid with a frequency type of `.weekly`.
    public var daysOfTheMonth: [Int]
    /// The days of the year associated with the recurrence rule, as an array of `Int`. Values can be from 1 to 366 and from -1 to -366. This property value is valid only for recurrence rules initialized with a frequency type of `.yearly`.
    public let daysOfTheYear: [Int]?
    /// The weeks of the year associated with the recurrence rule, as an array of `Int` objects. Values can be from 1 to 53 and from -1 to -53. This property value is valid only for recurrence rules initialized with specific weeks of the year and a frequency type of `.yearly`.
    public let weeksOfTheYear: [Int]?
    /// The months of the year associated with the recurrence rule, as an array of `Int` objects. Values can be from 1 to 12. This property value is valid only for recurrence rules initialized with specific months of the year and a frequency type of `.yearly`.
    public var monthsOfTheYear: [Int]
    /// An array of ordinal numbers that filters which recurrences to include in the recurrence rule’s frequency. For example, a yearly recurrence rule that has a daysOfTheWeek value that specifies Monday through Friday, and a setPositions array containing 2 and -1, occurs only on the second weekday and last weekday of every year.
    public let setPositions: [Int]?
    /// Indicates when the recurrence rule ends. This can be represented by an end date or a number of occurrences.
    public var recurrenceEnd: RecurrenceEnd?

    public var timeZoneIdentifier: String?

    public var dateStart: Date?

    /// Initializes and returns a recurrence rule with a given frequency and additional scheduling information.
    ///
    /// Returns `nil` is any invalid parameters are provided.
    ///
    /// Negative value indicate counting backwards from the end of the recurrence rule's frequency.
    ///
    /// - Parameters:
    ///   - type: The frequency of the recurrence rule. Can be daily, weekly, monthly, or yearly.
    ///   - interval: The interval between instances of this recurrence. For example, a weekly recurrence rule with an interval of `2` occurs every other week. Must be greater than `0`.
    ///   - days: The days of the week that the event occurs, as an array of `RecurrenceDayOfWeek` objects.
    ///   - monthDays: The days of the month that the event occurs, as an array of `Int`. Values can be from 1 to 31 and from -1 to -31. This parameter is not valid for recurrence rules of type `.weekly`.
    ///   - months: The months of the year that the event occurs, as an array of `Int`. Values can be from 1 to 12.
    ///   - weeksOfTheYear: The weeks of the year that the event occurs, as an array of `Int`. Values can be from 1 to 53 and from -1 to -53. This parameter is only valid for recurrence rules of type `.yearly`.
    ///   - daysOfTheYear: The days of the year that the event occurs, as an array of `Int`. Values can be from 1 to 366 and from -1 to -366. This parameter is only valid for recurrence rules of type `.yearly`.
    ///   - setPositions: An array of ordinal numbers that filters which recurrences to include in the recurrence rule’s frequency. See `setPositions` for more information.
    ///   - end: The end of the recurrence rule.
    ///   - firstDay: Indicates what day of the week to be used as the first day of a week. Defaults to Monday.
    public init?(
        recurrenceWith type: RecurrenceFrequency,
        interval: Int = 1,
        daysOfTheWeek days: [RecurrenceDayOfWeek] = [],
        daysOfTheMonth monthDays: [Int] = [],
        monthsOfTheYear: [Int] = [],
        weeksOfTheYear: [Int]? = nil,
        daysOfTheYear: [Int]? = nil,
        setPositions: [Int]? = nil,
        end: RecurrenceEnd? = nil,
        firstDay: Weekday? = nil,
        timeZoneIdentifier _: String? = nil,
        dateStart _: String? = nil
    ) {
        // NOTE - See https://icalendar.org/iCalendar-RFC-5545/3-3-10-recurrence-rule.html

        if interval <= 0 { return nil } // INTERVAL must be 1 or more
        // In daily or weekly mode or in yearly mode with week numbers, the days should not have a week number.
        if !days.isEmpty {
            if (type != .monthly && type != .yearly) || (type == .yearly && weeksOfTheYear != nil) {
                for day in days {
                    if day.weekNumber != 0 { return nil }
                }
            }
        }
        if !monthDays.isEmpty {
            guard type != .weekly else { return nil }

            for day in monthDays {
                if day < -31 || day > 31 || day == 0 { return nil }
            }
        }

        if !monthsOfTheYear.isEmpty {
            for month in monthsOfTheYear {
                if month < 1 || month > 12 { return nil }
            }
        }
        if let weeksOfTheYear {
            guard type == .yearly else { return nil }

            for week in weeksOfTheYear {
                if week < -53 || week > 53 || week == 0 { return nil }
            }
        }
        if let daysOfTheYear {
            // Also supported by secondly, minutely, and hourly
            guard type == .yearly else { return nil }

            for day in daysOfTheYear {
                if day < -366 || day > 366 || day == 0 { return nil }
            }
        }
        if let setPositions {
            for pos in setPositions {
                if pos < -366 || pos > 366 || pos == 0 { return nil }
            }
        }

        // TODO: Validate minutely & hourly

        frequency = type
        self.interval = interval
        firstDayOfTheWeek = firstDay
        daysOfTheWeek = days
        daysOfTheMonth = monthDays
        self.daysOfTheYear = daysOfTheYear
        self.weeksOfTheYear = weeksOfTheYear
        self.monthsOfTheYear = monthsOfTheYear
        self.setPositions = setPositions
        recurrenceEnd = end
    }
}
