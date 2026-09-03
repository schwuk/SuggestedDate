# ``SuggestedDate``

Date suggestion utilities for task and reminder due date selection.

## Overview

SuggestedDate provides a simple API for computing common date suggestions: "today", "tomorrow", "next working day", "next week", "in one/two weeks", and "end of this/next week". All calculations respect the provided calendar's locale, time zone, and weekend definitions.

### Basic Usage

```swift
import SuggestedDate

// Get next working day
let nextWorkday = SuggestedDate.nextWorkingDay.date()

// Get the suggestions appropriate for a picker, given the current date
for suggestion in SuggestedDate.suggestions(for: Date()) {
    print("\(suggestion.description): \(suggestion.date())")
}
```

Use ``SuggestedDate/suggestions(for:calendar:)`` rather than `allCases` when populating a picker — it excludes `endOfThisWeek` when it would duplicate `endOfNextWeek`. ``SuggestedDate/defaultSuggestions`` returns just the point-in-time cases, useful for a simpler settings picker.

### Deadlines vs. Points in Time

Most cases (`today`, `tomorrow`, `inOneWeek`, ...) suggest an exact point in time. `endOfThisWeek` and `endOfNextWeek` instead suggest a deadline — the last working day before a cutoff. ``SuggestedDate/isDeadline`` distinguishes the two, which is useful for phrasing ("Due on" vs "Due by") in UI:

```swift
let suggestion = SuggestedDate.endOfThisWeek
let label = suggestion.isDeadline ? "Due by" : "Due on"
```

### Custom Calendars

All date calculations can use a custom calendar for locale-specific behavior:

```swift
var calendar = Calendar(identifier: .gregorian)
calendar.timeZone = TimeZone(identifier: "Europe/London")!

let date = SuggestedDate.nextWeek.date(
    onOrAfter: Date(),
    calendar: calendar
)
```

### Custom Date Suggestions

Implement ``DateSuggesting`` to create your own suggestions:

```swift
struct NextPayday: DateSuggesting {
    func date(onOrAfter: Date, calendar: Calendar) -> Date {
        // Compute and return the next 15th, or last day of month
        calendar.startOfDay(for: onOrAfter) // placeholder
    }
}
```
