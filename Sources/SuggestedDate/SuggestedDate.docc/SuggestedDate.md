# ``SuggestedDate``

Date suggestion utilities for task and reminder due date selection.

## Overview

SuggestedDate provides a simple API for computing common date suggestions like "today", "tomorrow", "next working day", and "next week". All calculations respect the provided calendar's locale, time zone, and weekend definitions.

### Basic Usage

```swift
import SuggestedDate

// Get next working day
let nextWorkday = SuggestedDate.nextWorkingDay.date()

// Iterate all suggestions
for suggestion in SuggestedDate.allCases {
    print("\(suggestion.description): \(suggestion.date())")
}
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
        // Return the next 15th or last day of month
    }
}
```

## Topics

### Essentials

- ``SuggestedDate``
- ``DateSuggesting``

### Date Suggestions

- ``SuggestedDate/today``
- ``SuggestedDate/tomorrow``
- ``SuggestedDate/nextWorkingDay``
- ``SuggestedDate/nextWeek``

### Computing Dates

- ``SuggestedDate/date(onOrAfter:calendar:)``
- ``SuggestedDate/defaultSuggestions``

### Display

- ``SuggestedDate/description``
- ``SuggestedDate/id``
