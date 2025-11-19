//
//  SuggestedDateTests.swift
//  SuggestedDate
//
//  Created by David Murphy on 16/07/2025.
//

import Foundation
import Testing

@testable import SuggestedDate

@Suite("Tests for SuggestedDate enum") struct SuggestedDateTests {
    // Use a deterministic calendar and timezone in tests
    let gmt: TimeZone = TimeZone(secondsFromGMT: 0)!

    var calendarGMT: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = gmt
        return cal
    }

    // 2001-01-01 00:00:00 +0000 (Reference date)
    var date: Date = Date(timeIntervalSinceReferenceDate: 0)

    @Test("Test Identifiable conformity")
    func testIdentifiable() throws {
        let suggestedDate: SuggestedDate = .today
        #expect(suggestedDate.id == SuggestedDate.today)
    }

    @Test("Test CustomStringConvertible conformity")
    func testTitle() {
        var suggestedDate: SuggestedDate = .today
        #expect(suggestedDate.description == "Today")
        suggestedDate = .tomorrow
        #expect(suggestedDate.description == "Tomorrow")
        suggestedDate = .nextWorkingDay
        #expect(suggestedDate.description == "Next Working Day")
        suggestedDate = .nextWeek
        #expect(suggestedDate.description == "Next Week")
    }

    @Test("Today returns start of day")
    func testSuggestedDueDateToday() throws {
        let suggestedDate: SuggestedDate = .today
        let result = suggestedDate.date(onOrAfter: date, calendar: calendarGMT)
        #expect(result == calendarGMT.startOfDay(for: date))
    }

    @Test("Tomorrow returns next day's start of day")
    func testSuggestedDueDateTomorrow() throws {
        let suggestedDate: SuggestedDate = .tomorrow
        let result = suggestedDate.date(onOrAfter: date, calendar: calendarGMT)
        let expected = calendarGMT.startOfDay(
            for: calendarGMT.date(byAdding: .day, value: 1, to: date)!
        )
        #expect(result == expected)
    }

    @Test("Next working day skips weekend and returns start of day")
    func testSuggestedDueDateNextWorkingDay() throws {
        // Set reference to a Friday: 2001-01-05 10:00 GMT
        var comps = DateComponents()
        comps.year = 2001
        comps.month = 1
        comps.day = 5
        comps.hour = 10
        comps.minute = 0
        let friday = calendarGMT.date(from: comps)!

        let suggestedDate: SuggestedDate = .nextWorkingDay
        let result = suggestedDate.date(
            onOrAfter: friday,
            calendar: calendarGMT
        )

        // Expect Monday 2001-01-08 00:00 GMT
        comps.day = 8
        comps.hour = 0
        comps.minute = 0
        let expected = calendarGMT.date(from: comps)!
        #expect(result == expected)
    }

    @Test("Next week returns the first weekday's start of day")
    func testSuggestedDueDateNextWeek() throws {
        let suggestedDate: SuggestedDate = .nextWeek
        let result = suggestedDate.date(onOrAfter: date, calendar: calendarGMT)

        // calendarGMT.firstWeekday is 1 (Sunday) by default in Gregorian for en_US, but to be robust,
        // compute using nextDate with the same calendar.
        let expected =
            calendarGMT.nextDate(
                after: date,
                matching: DateComponents(
                    hour: 0,
                    minute: 0,
                    second: 0,
                    weekday: calendarGMT.firstWeekday
                ),
                matchingPolicy: .nextTime
            ).map { calendarGMT.startOfDay(for: $0) }
            ?? calendarGMT.startOfDay(for: date)

        #expect(result == expected)
    }

    @Test("Next week across DST returns start of day in specified time zone")
    func testSuggestedDueDateNextWeekWithDST() throws {
        // Europe/London observes DST. Choose a date in September when DST is active.
        let london = TimeZone(identifier: "Europe/London")!
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = london

        let formatter = DateFormatter()
        formatter.calendar = cal
        formatter.timeZone = london
        formatter.dateFormat = "yyyy/MM/dd HH:mm"

        let fixedDate = formatter.date(from: "2025/09/16 10:31")!  // Tuesday

        // Expected: first weekday (per calendar) after fixedDate at 00:00 in London
        let expected = cal.nextDate(
            after: fixedDate,
            matching: DateComponents(
                hour: 0,
                minute: 0,
                second: 0,
                weekday: cal.firstWeekday
            ),
            matchingPolicy: .nextTime
        ).map { cal.startOfDay(for: $0) }!

        let suggestedDate: SuggestedDate = .nextWeek
        let result = suggestedDate.date(onOrAfter: fixedDate, calendar: cal)

        #expect(result == expected)
    }

    @Test("Next working day from Monday morning")
    func testNextWorkingDayFromMondayMorning() throws {
        var comps = DateComponents()
        comps.year = 2001
        comps.month = 1
        comps.day = 1
        comps.hour = 09
        comps.minute = 00
        let mondayMorning = calendarGMT.date(from: comps)!

        let result = SuggestedDate.nextWorkingDay.date(
            onOrAfter: mondayMorning,
            calendar: calendarGMT
        )

        comps.day = 2
        comps.hour = 0
        comps.minute = 0
        let expectedMonday = calendarGMT.date(from: comps)!
        #expect(result == expectedMonday)
    }

    @Test("Next working day from Friday evening")
    func testNextWorkingDayFromFridayEvening() throws {
        var comps = DateComponents()
        comps.year = 2001
        comps.month = 1
        comps.day = 5
        comps.hour = 23
        comps.minute = 59
        let fridayEvening = calendarGMT.date(from: comps)!

        let result = SuggestedDate.nextWorkingDay.date(
            onOrAfter: fridayEvening,
            calendar: calendarGMT
        )

        comps.day = 8
        comps.hour = 0
        comps.minute = 0
        let expectedMonday = calendarGMT.date(from: comps)!
        #expect(result == expectedMonday)
    }

    @Test("Next working day from Saturday morning")
    func testNextWorkingDayFromSaturdayMorning() throws {
        var comps = DateComponents()
        comps.year = 2001
        comps.month = 1
        comps.day = 6
        comps.hour = 00
        comps.minute = 00
        let saturdayMorning = calendarGMT.date(from: comps)!

        let result = SuggestedDate.nextWorkingDay.date(
            onOrAfter: saturdayMorning,
            calendar: calendarGMT
        )

        comps.day = 8
        comps.hour = 0
        comps.minute = 0
        let expectedMonday = calendarGMT.date(from: comps)!
        #expect(result == expectedMonday)
    }
}
