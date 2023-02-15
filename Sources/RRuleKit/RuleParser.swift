//
//  RuleParser.swift
//  RRuleKit
//
//  Created by Richard W Maddy on 5/13/18.
//  Copyright © 2018 Maddysoft. All rights reserved.
//

import Foundation

public class RuleParser {
    private lazy var untilFormat: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyyMMdd'T'HHmmssX"
        return df
    }()

    private lazy var dateStartFormat: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyyMMdd'T'HHmmss"
        return df
    }()

    public init() {}

    /// Compares two RRULE strings to see if they have the same components. The components do not need to be in the
    /// same order. Any `UNTIL` clause is ignored since the date can be in a different format.
    ///
    /// - Parameters:
    ///   - left: The first RRULE string.
    ///   - right: The second RRULE string.
    /// - Returns: `true` if the two rules have the same components, ignoring order and any `UNTIL` clause. `false` if
    /// different.
    public func compare(rule left: String, to right: String) -> Bool {
        var leftParts = split(rule: left).sorted()
        var rightParts = split(rule: right).sorted()
        if leftParts.first(where: { $0.hasPrefix("UNTIL") }) != nil,
           rightParts.first(where: { $0.hasPrefix("UNTIL") }) != nil
        {
            leftParts = leftParts.filter { !$0.hasPrefix("UNTIL") }
            rightParts = leftParts.filter { !$0.hasPrefix("UNTIL") }
        }

        return leftParts == rightParts
    }

    private func split(rule: String) -> [String] {
        var r = rule.uppercased()
        if r.hasPrefix("RRULE:") {
            r.removeFirst(6)
        }

        let parts = r.components(separatedBy: ";")

        return parts
    }

    /// Parses an RRULE string returning a `RecurrenceRule`.
    ///
    /// Valid strings:
    ///   - The RRULE string may optionally begin with `RRULE:`.
    ///   - There must be 1 `FREQ=` followed by either `DAILY`, `WEEKLY`, `MONTHLY`, `YEARLY`.
    ///   - There may be 1 `COUNT=` followed by a positive integer.
    ///   - There may be 1 `UNTIL=` followed by a date. The date may be in one of these formats: "yyyyMMdd'T'HHmmssX",
    /// "yyyyMMdd'T'HHmmss", "'TZID'=VV:yyyyMMdd'T'HHmmss", "yyyyMMdd".
    ///   - Only 1 of either `COUNT` or `UNTIL` is allowed, not both.
    ///   - There may be 1 `INTERVAL=` followed by a positive integer.
    ///   - There may be 1 `BYMONTH=` followed by a comma separated list of 1 or more month numbers in the range 1 to
    /// 12, or -12 to -1.
    ///   - There may be 1 `BYDAY=` followed by a comma separated list of 1 or more days of the week, each optionally
    /// preceded by a week number. Days of the week must be `SU`, `MO`, `TU`, `WE`, `TH`, `FR`, or `SA`. Week numbers
    /// must be in the range 1 to 5 or -5 to -1.
    ///   - There may be 1 `BYMONTHDAY=` followed by a comma separated list of days of the month in the range 1 to 31 or
    /// -31 to -1.
    ///   - There may be 1 `BYYEARDAY=` followed by a comma separated list of days of the year in the range 1 to 366 or
    /// -366 to -1.
    ///   - There may be 1 `BYWEEKNO=` followed by a comma separated list of week numbers in the range 1 to 53 or -53 to
    /// -1.
    ///   - There may be 1 `WKST=` followed by a day of the week. Days of the week must be `SU`, `MO`, `TU`, `WE`, `TH`,
    /// `FR`, or `SA`.
    ///   - There may be 1 `BYSETPOS=` following by a comma separated list of positive integers.
    ///   - Each clause must be separated by a semicolon (`;`). No trailing semicolon should be used.
    ///
    /// - Parameter rule: The RRULE string.
    /// - Returns: The resulting recurrence rule. If the RRULE string is invalid in any way, the result is `nil`.
    public func parse(rule: String) -> RecurrenceRule? {
        var frequency: RecurrenceFrequency?
        var interval: Int?
        var firstDayOfTheWeek: Weekday?
        var daysOfTheWeek: [RecurrenceDayOfWeek]?
        var daysOfTheMonth: [Int]?
        var daysOfTheYear: [Int]?
        var weeksOfTheYear: [Int]?
        var monthsOfTheYear: [Int]?
        var setPositions: [Int]?
        var recurrenceEnd: RecurrenceEnd?

        let parts = split(rule: rule)
        for part in parts {
            let varval = part.components(separatedBy: "=")
            guard varval.count == 2 else { return nil }

            switch varval[0] {
            case "FREQ":
                guard frequency == nil else { return nil } // only allowed one FREQ
                frequency = parse(frequency: varval[1])
                guard frequency != nil else { return nil } // invalid FREQ value
            case "COUNT":
                guard recurrenceEnd == nil else { return nil } // only one of either COUNT or UNTIL, not both
                recurrenceEnd = parse(count: varval[1])
                guard recurrenceEnd != nil else { return nil } // invalid COUNT
            case "UNTIL":
                guard recurrenceEnd == nil else { return nil } // only one of either COUNT or UNTIL, not both
                recurrenceEnd = parse(until: varval[1])
                guard recurrenceEnd != nil else { return nil } // invalid UNTIL
            case "INTERVAL":
                guard interval == nil else { return nil } // only allowed one INTERVAL
                interval = parse(interval: varval[1])
                guard interval != nil else { return nil } // invalid INTERVAL
            case "BYMONTH":
                guard monthsOfTheYear == nil else { return nil } // only allowed one BYMONTH
                monthsOfTheYear = parse(byMonth: varval[1])
                guard monthsOfTheYear != nil else { return nil } // invalid BYMONTH
            case "BYDAY":
                guard daysOfTheWeek == nil else { return nil } // only allowed one BYDAY
                daysOfTheWeek = parse(byDay: varval[1])
                guard daysOfTheWeek != nil else { return nil } // invalid BYDAY
            case "WKST":
                guard firstDayOfTheWeek == nil else { return nil } // only allowed one WKST
                firstDayOfTheWeek = parse(byWeekStart: varval[1])
                guard firstDayOfTheWeek != nil else { return nil } // invalid WKST
            case "BYMONTHDAY":
                guard daysOfTheMonth == nil else { return nil } // only allowed one BYMONTHDAY
                daysOfTheMonth = parse(byMonthDay: varval[1])
                guard daysOfTheMonth != nil else { return nil } // invalid BYMONTHDAY
            case "BYYEARDAY":
                guard daysOfTheYear == nil else { return nil } // only allowed one BYYEARDAY
                daysOfTheYear = parse(byYearDay: varval[1])
                guard daysOfTheYear != nil else { return nil } // invalid BYYEARDAY
            case "BYWEEKNO":
                guard weeksOfTheYear == nil else { return nil } // only allowed one BYWEEKNO
                weeksOfTheYear = parse(byWeekNo: varval[1])
                guard weeksOfTheYear != nil else { return nil } // invalid BYWEEKNO
            case "BYSETPOS":
                guard setPositions == nil else { return nil } // only allowed one BYSETPOS
                setPositions = parse(bySetPosition: varval[1])
                guard setPositions != nil else { return nil } // invalid BYSETPOS
            /* Not supported by EKRecurrenceRule
             case "BYHOUR":
                 return nil
             case "BYMINUTE":
                 return nil
             case "BYSECOND":
                 return nil
                  */
            case "DTSTART":
                break
            default:
                return nil
            }
        }

        if
            let frequency,
            let interval,
            let daysOfTheWeek,
            let daysOfTheMonth,
            let monthsOfTheYear
        {
            return RecurrenceRule(
                recurrenceWith: frequency,
                interval: interval,
                daysOfTheWeek: daysOfTheWeek,
                daysOfTheMonth: daysOfTheMonth,
                monthsOfTheYear: monthsOfTheYear,
                weeksOfTheYear: weeksOfTheYear,
                daysOfTheYear: daysOfTheYear,
                setPositions: setPositions,
                end: recurrenceEnd,
                firstDay: firstDayOfTheWeek
            )
        } else {
            return nil // no FREQ
        }
    }

    /// Returns the RRULE string represented by the provided recurrence rule.
    ///
    /// - Parameter from: The recurrence rule.
    /// - Returns: The RRULE string.
    public func rule(from: RecurrenceRule) -> String {
        var parts = [String]()
        parts.append("FREQ=\(string(from: from.frequency))")
        if from.interval > 1 {
            parts.append("INTERVAL=\(from.interval)")
        }

        if let end = from.recurrenceEnd {
            switch end {
            case let .end(date):
                let formatter = untilFormat
                if let timeZoneIdentifier = from.timeZoneIdentifier {
                    formatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
                }
                parts.append("UNTIL=\(untilFormat.string(from: date))")
            case let .occurrenceCount(count):
                parts.append("COUNT=\(count)")
            }
        }
        if let wkst = from.firstDayOfTheWeek {
            parts.append("WKST=\(string(from: wkst))")
        }
        if let nums = from.weeksOfTheYear {
            parts.append("BYWEEKNO=\(string(from: nums))")
        }
        let days = from.daysOfTheWeek.sorted { $0.dayOfTheWeek.rawValue < $1.dayOfTheWeek.rawValue }
        if !days.isEmpty, days != Weekday.allCases.map({ .init($0) }) {
            parts.append("BYDAY=\(string(from: days))")
        }
        let monthsOfTheYear = from.monthsOfTheYear.sorted(by: <)
        if !monthsOfTheYear.isEmpty, monthsOfTheYear != Array(1 ... 12) {
            parts.append("BYMONTH=\(string(from: monthsOfTheYear))")
        }
        let daysOfTheMonth = from.daysOfTheMonth.sorted(by: <)
        if !daysOfTheMonth.isEmpty, daysOfTheMonth != Array(1 ... 31) {
            parts.append("BYMONTHDAY=\(string(from: daysOfTheMonth))")
        }
        if let nums = from.daysOfTheYear {
            parts.append("BYYEARDAY=\(string(from: nums))")
        }
        if let nums = from.setPositions {
            parts.append("BYSETPOS=\(string(from: nums))")
        }

        return "RRULE:" + parts.joined(separator: ";")
    }

    public func dateStartString(from: RecurrenceRule) -> String? {
        guard let dateStart = from.dateStart, let timeZoneIdentifer = from.timeZoneIdentifier else {
            return nil
        }
        let formatter = dateStartFormat
        if let timeZoneIdentifier = from.timeZoneIdentifier {
            formatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        }
        return "DTSTART;TZID=\(timeZoneIdentifer):\(dateStartFormat.string(from: dateStart))"
    }

    /// Including date start
    public func fullRule(from: RecurrenceRule) -> String {
        let rule = rule(from: from)
        let dateStart = dateStartString(from: from)
        if let dateStart {
            return "\(dateStart)\n\(rule)"
        } else {
            return rule
        }
    }

    private func parse(frequency: String) -> RecurrenceFrequency? {
        switch frequency {
        case "DAILY":
            return .daily
        case "WEEKLY":
            return .weekly
        case "MONTHLY":
            return .monthly
        case "YEARLY":
            return .yearly
        case "HOURLY":
            return nil // not supported by EKRecurrenceRule
        case "MINUTELY":
            return nil // not supported by EKRecurrenceRule
        case "SECONDLY":
            return nil // not supported by EKRecurrenceRule
        default:
            return nil
        }
    }

    private func string(from: RecurrenceFrequency) -> String {
        switch from {
        case .minutely:
            return "MINUTELY"
        case .hourly:
            return "HOURLY"
        case .daily:
            return "DAILY"
        case .weekly:
            return "WEEKLY"
        case .monthly:
            return "MONTHLY"
        case .yearly:
            return "YEARLY"
        }
    }

    private func parse(count: String) -> RecurrenceEnd? {
        if let cnt = Int(count) {
            return .occurrenceCount(cnt)
        } else {
            return nil
        }
    }

    private func parse(until: String) -> RecurrenceEnd? {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        for format in ["yyyyMMdd'T'HHmmssX", "yyyyMMdd'T'HHmmss", "'TZID'=VV:yyyyMMdd'T'HHmmss", "yyyyMMdd"] {
            df.dateFormat = format
            if let date = df.date(from: until) {
                return .end(date)
            }
        }

        return nil
    }

    private func parse(interval: String) -> Int? {
        if let cnt = Int(interval) {
            return cnt
        } else {
            return nil
        }
    }

    private func parseNumberList(_ list: String) -> [Int]? {
        var res = [Int]()
        let parts = list.components(separatedBy: ",")
        for part in parts {
            if let num = Int(part) {
                res.append(num)
            } else {
                return nil
            }
        }

        return res
    }

    private func string(from: [Int]) -> String {
        from.map { String($0) }.joined(separator: ",")
    }

    private func parse(byMonth: String) -> [Int]? {
        parseNumberList(byMonth)
    }

    private func parse(byWeekStart: String) -> Weekday? {
        switch byWeekStart {
        case "SU":
            return .sunday
        case "MO":
            return .monday
        case "TU":
            return .tuesday
        case "WE":
            return .wednesday
        case "TH":
            return .thursday
        case "FR":
            return .friday
        case "SA":
            return .saturday
        default:
            return nil
        }
    }

    private func string(from: Weekday) -> String {
        switch from {
        case .sunday:
            return "SU"
        case .monday:
            return "MO"
        case .tuesday:
            return "TU"
        case .wednesday:
            return "WE"
        case .thursday:
            return "TH"
        case .friday:
            return "FR"
        case .saturday:
            return "SA"
        }
    }

    private func parse(byDay: String) -> [RecurrenceDayOfWeek]? {
        var res = [RecurrenceDayOfWeek]()
        let parts = byDay.components(separatedBy: ",")
        for part in parts {
            let scanner = Scanner(string: part)
            var count = 0
            scanner.scanInt(&count)
            var weekday: NSString?
            if scanner.scanCharacters(from: .alphanumerics, into: &weekday), scanner.isAtEnd {
                if let weekday, let dow = parse(byWeekStart: weekday as String) {
                    let rec = count == 0 ? RecurrenceDayOfWeek(dayOfTheWeek: dow) :
                        RecurrenceDayOfWeek(dayOfTheWeek: dow, weekNumber: count)
                    res.append(rec)
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }

        return res
    }

    private func string(from: [RecurrenceDayOfWeek]) -> String {
        from.map {
            var res = ""
            if $0.weekNumber != 0 {
                res += String($0.weekNumber)
            }
            res += string(from: $0.dayOfTheWeek)
            return res
        }.joined(separator: ",")
    }

    private func parse(byMonthDay: String) -> [Int]? {
        parseNumberList(byMonthDay)
    }

    private func parse(byYearDay: String) -> [Int]? {
        parseNumberList(byYearDay)
    }

    private func parse(byWeekNo: String) -> [Int]? {
        parseNumberList(byWeekNo)
    }

    private func parse(bySetPosition: String) -> [Int]? {
        parseNumberList(bySetPosition)
    }
}
