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
/// - The returned date should be greater than or equal to the input date, as
///   interpreted by the supplied calendar.
///
/// - Parameters:
///   - onOrAfter: The reference date from which to compute the suggestion. The
///     returned date should be on or after this value.
///   - calendar: The calendar used to interpret date components, boundaries,
///     and locale-specific rules (e.g., start of day, weekdays, DST).
/// - Returns: A Date that represents the next valid suggestion on or after
///   the provided reference date according to the implementation’s rules.
public protocol DateSuggesting {
    func date(onOrAfter: Date, calendar: Calendar) -> Date
}
