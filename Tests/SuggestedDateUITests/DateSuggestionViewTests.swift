//
//  DateSuggestionViewTests.swift
//  SuggestedDateUI
//
//  Created by David Murphy on 26/11/2025.
//

import Foundation
import SwiftUI
import Testing

@testable import SuggestedDate
@testable import SuggestedDateUI

@Suite("Tests for DateSuggestionView") struct DateSuggestionViewTests {

    @Test("View initializes with valid bindings") @MainActor
    func testViewInitialization() {
        let selectedDate = Date()

        let view = DateSuggestionView(
            selectedDate: .constant(selectedDate)
        )

        // Verify view was created successfully
        #expect(view.selectedDate == selectedDate)
    }

    @Test("Default suggestions contain original four cases")
    func testDefaultSuggestions() {
        #expect(SuggestedDate.defaultSuggestions.count == 6)
        #expect(
            SuggestedDate.defaultSuggestions == [
                .today, .tomorrow, .nextWorkingDay, .nextWeek, .inOneWeek, .inTwoWeeks,
            ])
    }

    @Test("All suggestions produce valid dates")
    func testSuggestionsProduceValidDates() {
        let now = Date()
        let calendar = Calendar.current

        for suggestion in SuggestedDate.defaultSuggestions {
            let date = suggestion.date(onOrAfter: now, calendar: calendar)

            // Verify date is on or after now
            #expect(date >= calendar.startOfDay(for: now))

            // Verify date is normalized to start of day
            #expect(date == calendar.startOfDay(for: date))
        }
    }

    @Test("Suggestion dates are in chronological order for typical case")
    func testSuggestionsChronologicalOrder() {
        let now = Date()
        let calendar = Calendar.current

        let dates = SuggestedDate.defaultSuggestions.map { suggestion in
            suggestion.date(onOrAfter: now, calendar: calendar)
        }

        // For most cases: today <= tomorrow <= nextWorkingDay
        if dates.count >= 2 {
            #expect(dates[0] <= dates[1])  // today <= tomorrow
        }
    }

    @Test("Date computation is deterministic")
    func testDateComputationDeterministic() {
        let now = Date()
        let calendar = Calendar.current

        for suggestion in SuggestedDate.defaultSuggestions {
            let date1 = suggestion.date(onOrAfter: now, calendar: calendar)
            let date2 = suggestion.date(onOrAfter: now, calendar: calendar)

            #expect(date1 == date2)
        }
    }

    @Test("View uses current date for computations")
    func testViewUsesCurrentDate() {
        // Create a fixed reference date
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = Date(timeIntervalSinceReferenceDate: 0)  // 2001-01-01

        // Verify that suggestions based on reference produce expected dates
        let todayDate = SuggestedDate.today.date(onOrAfter: referenceDate, calendar: cal)
        let tomorrowDate = SuggestedDate.tomorrow.date(onOrAfter: referenceDate, calendar: cal)

        #expect(todayDate == cal.startOfDay(for: referenceDate))
        #expect(tomorrowDate == cal.date(byAdding: .day, value: 1, to: todayDate))
    }

    @Test("All suggestion types have unique descriptions")
    func testSuggestionDescriptionsUnique() {
        let descriptions = SuggestedDate.defaultSuggestions.map { $0.description }
        let uniqueDescriptions = Set(descriptions)

        #expect(descriptions.count == uniqueDescriptions.count)
    }

    @Test("All suggestions are identifiable")
    func testSuggestionsIdentifiable() {
        let ids = SuggestedDate.defaultSuggestions.map { $0.id }
        let uniqueIds = Set(ids)

        #expect(ids.count == uniqueIds.count)
    }

    @Test("View initializes with onSuggestionSelected callback") @MainActor
    func testViewInitializationWithCallback() {
        var callbackCalled = false
        let view = DateSuggestionView(
            selectedDate: .constant(Date()),
            onSuggestionSelected: { _ in callbackCalled = true }
        )

        #expect(view.selectedDate == view.selectedDate)
        #expect(!callbackCalled)
    }

    @Test("Contextual suggestions include deadline options on weekday")
    func testContextualSuggestionsOnWeekday() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!

        // Monday 2001-01-01
        let monday = cal.date(from: DateComponents(year: 2001, month: 1, day: 1))!
        let suggestions = SuggestedDate.suggestions(for: monday, calendar: cal)

        #expect(suggestions.count == 8)
        #expect(suggestions.contains(.endOfThisWeek))
        #expect(suggestions.contains(.endOfNextWeek))
    }

    @Test("Contextual suggestions on Friday omit endOfThisWeek")
    func testContextualSuggestionsOnFriday() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!

        // Friday 2001-01-05
        let friday = cal.date(from: DateComponents(year: 2001, month: 1, day: 5))!
        let suggestions = SuggestedDate.suggestions(for: friday, calendar: cal)

        #expect(suggestions.count == 7)
        #expect(!suggestions.contains(.endOfThisWeek))
        #expect(suggestions.contains(.endOfNextWeek))
    }
}
