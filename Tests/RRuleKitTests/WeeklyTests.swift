//
//  WeeklyTests.swift
//  RecurrenceRuleTests
//
//  Created by Richard W Maddy on 5/17/18.
//  Copyright © 2018 Maddysoft. All rights reserved.
//

@testable import RRuleKit
import XCTest

class WeeklyTests: XCTestCase {
    var parser = RuleParser()

    func testInitial() {
        let rule = RecurrenceRule(
            recurrenceWith: .weekly,
            end: nil
        )
        let ruleString = parser.rule(from: rule!)
        XCTAssertEqual(ruleString, "RRULE:FREQ=WEEKLY")
    }

    func testEvery2Weeks() {
        let rule = RecurrenceRule(
            recurrenceWith: .weekly,
            interval: 2,
            end: nil
        )
        let ruleString = parser.rule(from: rule!)
        XCTAssertEqual(ruleString, "RRULE:FREQ=WEEKLY;INTERVAL=2")
    }

    func testEvery2WeeksOnMondayAndThursday() {
        let rule = RecurrenceRule(
            recurrenceWith: .weekly,
            interval: 2,
            daysOfTheWeek: [
                .init(.monday),
                .init(.thursday),
            ],
            end: nil
        )
        let ruleString = parser.rule(from: rule!)
        XCTAssertEqual(ruleString, "RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,TH")
    }

    func testEvery2WeeksOnAllWeekDays() {
        let rule = RecurrenceRule(
            recurrenceWith: .weekly,
            interval: 2,
            daysOfTheWeek: Weekday.allCases.map { .init($0) },
            end: nil
        )
        let ruleString = parser.rule(from: rule!)
        XCTAssertEqual(ruleString, "RRULE:FREQ=WEEKLY;INTERVAL=2")
    }

    // TODO: Add more tests
}
