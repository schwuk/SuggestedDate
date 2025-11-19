//
//  SuggestedDate.swift
//  SuggestedDate
//
//  Created by David Murphy on 16/07/2025.
//

import Foundation

/// An enumeration that represents various due date options for tasks or reminders.
///
/// The `SuggestedDate` enum provides a set of predefined date options, such as "today," "tomorrow," or "next working day,"
/// to simplify the selection and handling of dates within the application. Each case can generate a suggested
/// `Date` value, offer a human-readable description, and be uniquely identified for use in lists or selection controls.
///
/// - Conforms to:
///   - `String`: Raw values for serialization and easy display.
///   - `CaseIterable`: To iterate over all possible cases.
///   - `CustomStringConvertible`: For readable string representation.
///   - `Identifiable`: For unique identification in SwiftUI collections.
///
/// Cases:
///   - `today`: The current day.
///   - `tomorrow`: The day after the current day.
///   - `nextWorkingDay`: The next weekday, skipping weekends.
///   - `nextWeek`: The first day of the next week.
public enum SuggestedDate: String, CaseIterable, CustomStringConvertible, Identifiable,
    Codable, Sendable, Hashable, DateSuggesting
{
    case today
    case tomorrow
    case nextWorkingDay
    case nextWeek

    /// A unique identifier for each `SuggestedDate` case.
    ///
    /// Conforms to the `Identifiable` protocol by returning `self` for the `id` property,
    /// allowing each enumeration case to be uniquely identified.
    public var id: Self { self }

    /// A human-readable string representation of the due date option.
    ///
    /// - Returns: A string describing the case:
    ///   - `.today`: "Today"
    ///   - `.tomorrow`: "Tomorrow"
    ///   - `.nextWorkingDay`: "Next Working Day"
    ///   - `.nextWeek`: "Next Week"
    public var description: String {
        switch self {
        case .today: return "Today"
        case .tomorrow: return "Tomorrow"
        case .nextWorkingDay: return "Next Working Day"
        case .nextWeek: return "Next Week"
        }
    }

    public static var defaultSuggestions: [SuggestedDate] { allCases }

    /// Returns a suggested date based on the selected case.
    ///
    /// This method computes a normalized date (start of day) relative to the supplied
    /// reference date using the provided calendar. The behavior varies by case:
    /// - `.today`: The start of the reference day.
    /// - `.tomorrow`: The start of the next day.
    /// - `.nextWorkingDay`: The start of the next weekday, skipping weekend days as
    ///   determined by the calendar’s weekend rules.
    /// - `.nextWeek`: The start of the first day of the next week, using the calendar’s
    ///   `firstWeekday` to determine the week boundary.
    ///
    /// - Parameters:
    ///   - onOrAfter: The reference date from which to calculate the suggestion. Defaults to the current date and time.
    ///   - calendar: The calendar used for date calculations and weekend/weekday determination. Defaults to `.current`.
    /// - Returns: A `Date` representing the suggested date at the start of day in the given calendar.
    public func date(
        onOrAfter: Date = Date(),
        calendar: Calendar = .current
    ) -> Date {
        switch self {
        case .today: return startOfDay(for: onOrAfter, calendar: calendar)
        case .tomorrow: return tomorrow(from: onOrAfter, calendar: calendar)
        case .nextWorkingDay:
            return nextWorkingDay(after: onOrAfter, calendar: calendar)
        case .nextWeek: return nextWeek(from: onOrAfter, calendar: calendar)
        }
    }

    /// Returns the start of the day for a given date using the specified calendar.
    ///
    /// This helper normalizes any time component on the provided date to midnight (00:00:00)
    /// according to the calendar’s locale and time zone. It is useful for comparing dates
    /// at day-level granularity and for generating consistent "all-day" values.
    ///
    /// - Parameters:
    ///   - date: The input `Date` whose day boundary should be computed.
    ///   - calendar: The `Calendar` that defines the day boundary, locale, and time zone.
    /// - Returns: A `Date` representing midnight at the start of the specified day.
    public func startOfDay(
        for date: Date,
        calendar: Calendar
    ) -> Date {
        calendar.startOfDay(for: date)
    }

    private func tomorrow(
        from: Date = Date(),
        calendar: Calendar = .current
    ) -> Date {
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: from) ?? from
        return startOfDay(for: tomorrow, calendar: calendar)
    }

    private func nextWorkingDay(
        after: Date = Date(),
        calendar: Calendar = .current
    ) -> Date {
        var nextDate = after
        repeat {
            nextDate =
                calendar.date(byAdding: .day, value: 1, to: nextDate)
                ?? nextDate
        } while calendar.isDateInWeekend(nextDate)

        return startOfDay(for: nextDate, calendar: calendar)
    }

    private func nextWeek(
        from: Date = Date(),
        calendar: Calendar = .current
    )
        -> Date
    {
        let nextWeek =
            calendar.nextDate(
                after: from,
                matching: DateComponents(
                    hour: 0,
                    minute: 0,
                    second: 0,
                    weekday: calendar.firstWeekday
                ),
                matchingPolicy: .nextTime
            ) ?? from

        return startOfDay(for: nextWeek, calendar: calendar)
    }
}
