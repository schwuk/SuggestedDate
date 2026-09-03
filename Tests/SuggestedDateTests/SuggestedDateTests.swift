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
        suggestedDate = .inOneWeek
        #expect(suggestedDate.description == "In One Week")
        suggestedDate = .inTwoWeeks
        #expect(suggestedDate.description == "In Two Weeks")
        suggestedDate = .endOfThisWeek
        #expect(suggestedDate.description == "End of This Week")
        suggestedDate = .endOfNextWeek
        #expect(suggestedDate.description == "End of Next Week")
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

    // MARK: - In _n_ Weeks

    @Test("In One Week adds seven days")
    func testInOneWeek() {
        // 2001-01-01 is Monday
        let monday = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 1)
        )!
        let result = SuggestedDate.inOneWeek.date(
            onOrAfter: monday,
            calendar: calendarGMT
        )
        // Friday 2001-01-08
        let expected = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 8)
        )!
        #expect(result == expected)
    }

    @Test("In Two Weeks adds fourteen days")
    func testInTwoWeeks() {
        // 2001-01-01 is Monday
        let monday = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 1)
        )!
        let result = SuggestedDate.inTwoWeeks.date(
            onOrAfter: monday,
            calendar: calendarGMT
        )
        // Friday 2001-01-15
        let expected = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 15)
        )!
        #expect(result == expected)
    }

    // MARK: - End of This Week

    @Test("End of this week on Monday returns Friday of that week")
    func testEndOfThisWeekFromMonday() {
        // 2001-01-01 is Monday
        let monday = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 1)
        )!
        let result = SuggestedDate.endOfThisWeek.date(
            onOrAfter: monday,
            calendar: calendarGMT
        )
        // Friday 2001-01-05
        let expected = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 5)
        )!
        #expect(result == expected)
    }

    @Test("End of this week on Thursday returns Friday of that week")
    func testEndOfThisWeekFromThursday() {
        // 2001-01-04 is Thursday
        let thursday = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 4)
        )!
        let result = SuggestedDate.endOfThisWeek.date(
            onOrAfter: thursday,
            calendar: calendarGMT
        )
        let expected = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 5)
        )!
        #expect(result == expected)
    }

    @Test("End of this week on Friday rolls forward to next Friday")
    func testEndOfThisWeekFromFriday() {
        // 2001-01-05 is Friday — already on last working day, should roll forward
        let friday = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 5)
        )!
        let result = SuggestedDate.endOfThisWeek.date(
            onOrAfter: friday,
            calendar: calendarGMT
        )
        // Next Friday: 2001-01-12
        let expected = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 12)
        )!
        #expect(result == expected)
    }

    @Test("End of this week on Saturday rolls forward to next Friday")
    func testEndOfThisWeekFromSaturday() {
        // 2001-01-06 is Saturday
        let saturday = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 6)
        )!
        let result = SuggestedDate.endOfThisWeek.date(
            onOrAfter: saturday,
            calendar: calendarGMT
        )
        let expected = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 12)
        )!
        #expect(result == expected)
    }

    @Test("End of this week on Sunday rolls forward to next Friday")
    func testEndOfThisWeekFromSunday() {
        // 2001-01-07 is Sunday
        let sunday = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 7)
        )!
        let result = SuggestedDate.endOfThisWeek.date(
            onOrAfter: sunday,
            calendar: calendarGMT
        )
        let expected = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 12)
        )!
        #expect(result == expected)
    }

    // MARK: - End of Next Week

    @Test("End of next week on Monday returns Friday of next week")
    func testEndOfNextWeekFromMonday() {
        // 2001-01-01 is Monday → next week's Friday = 2001-01-12
        let monday = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 1)
        )!
        let result = SuggestedDate.endOfNextWeek.date(
            onOrAfter: monday,
            calendar: calendarGMT
        )
        let expected = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 12)
        )!
        #expect(result == expected)
    }

    @Test("End of next week on Friday returns Friday of following week")
    func testEndOfNextWeekFromFriday() {
        // 2001-01-05 is Friday → next week's Friday = 2001-01-12
        let friday = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 5)
        )!
        let result = SuggestedDate.endOfNextWeek.date(
            onOrAfter: friday,
            calendar: calendarGMT
        )
        let expected = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 12)
        )!
        #expect(result == expected)
    }

    // MARK: - isDeadline

    @Test("isDeadline returns true only for deadline cases")
    func testIsDeadline() {
        #expect(!SuggestedDate.today.isDeadline)
        #expect(!SuggestedDate.tomorrow.isDeadline)
        #expect(!SuggestedDate.nextWorkingDay.isDeadline)
        #expect(!SuggestedDate.nextWeek.isDeadline)
        #expect(SuggestedDate.endOfThisWeek.isDeadline)
        #expect(SuggestedDate.endOfNextWeek.isDeadline)
    }

    // MARK: - suggestions(for:)

    @Test("Suggestions on Monday include both end-of-week options")
    func testSuggestionsOnMonday() {
        let monday = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 1)
        )!
        let suggestions = SuggestedDate.suggestions(
            for: monday,
            calendar: calendarGMT
        )
        #expect(suggestions.contains(.endOfThisWeek))
        #expect(suggestions.contains(.endOfNextWeek))
    }

    @Test("Suggestions on Friday exclude endOfThisWeek (matches endOfNextWeek)")
    func testSuggestionsOnFriday() {
        let friday = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 5)
        )!
        let suggestions = SuggestedDate.suggestions(
            for: friday,
            calendar: calendarGMT
        )
        #expect(!suggestions.contains(.endOfThisWeek))
        #expect(suggestions.contains(.endOfNextWeek))
    }

    @Test(
        "Suggestions on Saturday exclude endOfThisWeek (matches endOfNextWeek)"
    )
    func testSuggestionsOnSaturday() {
        let saturday = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 6)
        )!
        let suggestions = SuggestedDate.suggestions(
            for: saturday,
            calendar: calendarGMT
        )
        #expect(!suggestions.contains(.endOfThisWeek))
        #expect(suggestions.contains(.endOfNextWeek))
    }

    @Test("Suggestions always include the original four cases")
    func testSuggestionsAlwaysIncludeDefaults() {
        let monday = calendarGMT.date(
            from: DateComponents(year: 2001, month: 1, day: 1)
        )!
        let suggestions = SuggestedDate.suggestions(
            for: monday,
            calendar: calendarGMT
        )
        for suggestion in SuggestedDate.coreSuggestions {
            #expect(suggestions.contains(suggestion))
        }
    }

    @Test("coreSuggestions excludes deadline cases")
    func testCoreSuggestionsExcludeDeadlines() {
        let defaults = SuggestedDate.coreSuggestions
        #expect(defaults.count == 4)
        #expect(!defaults.contains(.endOfThisWeek))
        #expect(!defaults.contains(.endOfNextWeek))
    }

    @Test("extendedSuggestions excludes deadline cases")
    func testExtendedSuggestionsExcludeDeadlines() {
        let defaults = SuggestedDate.extendedSuggestions
        #expect(defaults.count == 6)
        #expect(!defaults.contains(.endOfThisWeek))
        #expect(!defaults.contains(.endOfNextWeek))
    }
}
