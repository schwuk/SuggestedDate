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
/// `Date` value via ``date(onOrAfter:calendar:)``, offer a human-readable description, and be uniquely
/// identified for use in lists or selection controls. All calculations are calendar- and timezone-aware.
///
/// ```swift
/// let dueDate = SuggestedDate.nextWorkingDay.date()
/// // On a Friday, returns the start of the following Monday.
/// ```
///
/// - Conforms to:
///   - `String` raw values: For serialization and stable storage.
///   - `CaseIterable`: To iterate over all possible cases.
///   - `CustomStringConvertible`: For readable string representation.
///   - `Identifiable`: For unique identification in SwiftUI collections.
///   - `Codable`, `Hashable`: For encoding and use in collections.
///   - `Sendable`: Safe to share across concurrency domains.
///   - ``DateSuggesting``: The package's date suggestion protocol.
///
/// Cases:
///   - `today`: The current day.
///   - `tomorrow`: The day after the current day.
///   - `nextWorkingDay`: The next weekday, skipping weekends.
///   - `nextWeek`: The first day of the next week.
///   - `inOneWeek`: Exactly one week after the reference date.
///   - `inTwoWeeks`: Exactly two weeks after the reference date.
///   - `endOfThisWeek`: The last working day of the current week. Rolls forward if already on or past it.
///   - `endOfNextWeek`: The last working day of next week.
public enum SuggestedDate: String, CaseIterable, CustomStringConvertible,
    Identifiable,
    Codable, Sendable, Hashable, DateSuggesting
{
    case today
    case tomorrow
    case nextWorkingDay
    case nextWeek
    case inOneWeek
    case inTwoWeeks
    case endOfThisWeek
    case endOfNextWeek

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
        case .inOneWeek: return "In One Week"
        case .inTwoWeeks: return "In Two Weeks"
        case .endOfThisWeek: return "End of This Week"
        case .endOfNextWeek: return "End of Next Week"
        }
    }

    /// Whether this suggestion represents a deadline (end-of-period) rather than a point in time.
    public var isDeadline: Bool {
        switch self {
        case .endOfThisWeek, .endOfNextWeek: return true
        default: return false
        }
    }

    /// The original four suggestions, suitable for settings pickers.
    public static var defaultSuggestions: [SuggestedDate] {
        [
            .today, .tomorrow, .nextWorkingDay, .nextWeek,
        ]
    }

    /// The extended set of suggestions, suitable for settings pickers.
    public static var extendedSuggestions: [SuggestedDate] {
        [
            .today, .tomorrow, .nextWorkingDay, .nextWeek, .inOneWeek,
            .inTwoWeeks,
        ]
    }

    /// Contextual suggestions including deadline options.
    ///
    /// Includes all suggestions in `base` plus applicable deadline suggestions.
    /// `endOfThisWeek` is excluded when it resolves to the same date as `endOfNextWeek`
    /// (i.e., when the reference date is on or past the last working day of the current week).
    public static func suggestions(
        for date: Date,
        calendar: Calendar = .current,
        base: [SuggestedDate] = extendedSuggestions
    ) -> [SuggestedDate] {
        var result = base

        let endThisWeek = SuggestedDate.endOfThisWeek.date(
            onOrAfter: date,
            calendar: calendar
        )
        let endNextWeek = SuggestedDate.endOfNextWeek.date(
            onOrAfter: date,
            calendar: calendar
        )

        if endThisWeek != endNextWeek {
            result.append(.endOfThisWeek)
        }
        result.append(.endOfNextWeek)

        return result
    }

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
    /// - `.inOneWeek`: The start of the day exactly one week after the reference date.
    /// - `.inTwoWeeks`: The start of the day exactly two weeks after the reference date.
    /// - `.endOfThisWeek`: The start of the last working day of the week containing the
    ///   reference date. If the reference date is already on or past that day, rolls
    ///   forward to the last working day of the following week.
    /// - `.endOfNextWeek`: The start of the last working day of the week after the one
    ///   containing the reference date.
    ///
    /// ```swift
    /// let calendar = Calendar.current
    /// let dueDate = SuggestedDate.nextWorkingDay.date(calendar: calendar)
    /// // On a Friday, returns the start of the following Monday.
    /// ```
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
        case .inOneWeek:
            return addWeeks(from: onOrAfter, calendar: calendar, weeks: 1)
        case .inTwoWeeks:
            return addWeeks(from: onOrAfter, calendar: calendar, weeks: 2)
        case .endOfThisWeek:
            return endOfThisWeek(from: onOrAfter, calendar: calendar)
        case .endOfNextWeek:
            return endOfNextWeek(from: onOrAfter, calendar: calendar)

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

    /// Returns the last working day of the week containing `from`.
    /// If `from` is already on or past the last working day, returns the last working day of the *next* week.
    private func endOfThisWeek(
        from: Date,
        calendar: Calendar
    ) -> Date {
        let lastWorkingDay = Self.lastWorkingDayOfWeek(
            containing: from,
            calendar: calendar
        )
        let today = startOfDay(for: from, calendar: calendar)

        if today >= lastWorkingDay {
            // Already on or past the last working day — roll forward to next week
            return endOfNextWeek(from: from, calendar: calendar)
        }
        return lastWorkingDay
    }

    /// Returns the last working day of the week after the one containing `from`.
    private func endOfNextWeek(
        from: Date,
        calendar: Calendar
    ) -> Date {
        let oneWeekLater =
            calendar.date(byAdding: .weekOfYear, value: 1, to: from) ?? from
        return Self.lastWorkingDayOfWeek(
            containing: oneWeekLater,
            calendar: calendar
        )
    }

    /// Finds the last non-weekend day in the calendar week containing `date`.
    ///
    /// Walks backward from the last day of the week until a non-weekend day is found.
    private static func lastWorkingDayOfWeek(
        containing date: Date,
        calendar: Calendar
    ) -> Date {
        // Find the start of the week containing this date
        let weekStart =
            calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date

        // The last day of the week is 6 days after the start
        let weekEnd =
            calendar.date(byAdding: .day, value: 6, to: weekStart) ?? date

        // Walk backward to find the last non-weekend day
        var candidate = weekEnd
        while calendar.isDateInWeekend(candidate) {
            candidate =
                calendar.date(byAdding: .day, value: -1, to: candidate)
                ?? candidate
        }

        return calendar.startOfDay(for: candidate)
    }

    /// Returns the start of day the given number of weeks after `from`.
    ///
    /// - Parameters:
    ///   - from: The reference date.
    ///   - calendar: The calendar used for the date arithmetic.
    ///   - weeks: The number of weeks to add. Defaults to 1.
    /// - Returns: The resulting date, normalized to the start of day. Falls back to `from` if the calendar calculation fails.
    private func addWeeks(from: Date, calendar: Calendar, weeks: Int = 1)
        -> Date
    {
        let future =
            calendar.date(byAdding: .weekOfYear, value: weeks, to: from) ?? from
        return calendar.startOfDay(for: future)
    }
}
