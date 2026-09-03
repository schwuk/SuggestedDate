//
//  DateSuggesting.swift
//  SuggestedDate
//
//  Created by David Murphy on 16/07/2025.
//

import Foundation

/// A protocol for types that can compute a suggested Date given a starting point.
///
/// Conforming types encapsulate logic to produce a deterministic date suggestion
/// on or after a provided reference date using a specified Calendar. This is
/// useful for features like:
/// - Suggesting the next scheduled reminder or appointment
/// - Determining the next available time slot
/// - Providing smart defaults in date/time pickers
///
/// Expected behavior:
/// - Implementations should be deterministic for the same inputs.
/// - No side effects (pure calculation).
/// - The returned date should fall on or after the reference date at day
///   granularity: never on an earlier day, but possibly earlier within the
///   same day (for example, the start of the reference day).
public protocol DateSuggesting {
    /// Computes the suggested date relative to a reference date.
    ///
    /// - Parameters:
    ///   - onOrAfter: The reference date from which to compute the suggestion.
    ///     The returned date falls on the same day or a later day.
    ///   - calendar: The calendar used to interpret date components, boundaries,
    ///     and locale-specific rules (e.g., start of day, weekdays, DST).
    /// - Returns: A `Date` representing the suggestion, no earlier than the day
    ///   containing the reference date according to the implementation’s rules.
    func date(onOrAfter: Date, calendar: Calendar) -> Date
}
