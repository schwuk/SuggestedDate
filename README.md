# SuggestedDate

[![CI](https://github.com/schwuk/SuggestedDate/actions/workflows/ci.yml/badge.svg)](https://github.com/schwuk/SuggestedDate/actions/workflows/ci.yml)
[![Swift 6.2](https://img.shields.io/badge/Swift-6.2-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%20|%20iOS%20|%20tvOS%20|%20watchOS%20|%20visionOS-blue.svg)](https://developer.apple.com)

Swift package providing date suggestion utilities for task/reminder due date selection.

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/schwuk/SuggestedDate.git", from: "0.1.0")
]
```

## Usage

```swift
import SuggestedDate

let suggestion = SuggestedDate.nextWorkingDay
let date = suggestion.date() // Returns next weekday at start of day
```

### Available Suggestions

- `today` - Start of current day
- `tomorrow` - Start of next day
- `nextWorkingDay` - Next weekday, skipping weekends
- `nextWeek` - First day of next week

### Custom Calendar

```swift
let date = SuggestedDate.nextWeek.date(
    onOrAfter: referenceDate,
    calendar: myCalendar
)
```

### Protocol Conformance

`SuggestedDate` conforms to:
- `Codable` - Serialization/persistence
- `Sendable` - Safe for async contexts
- `Hashable` - Use in Sets/Dictionaries
- `Identifiable` - SwiftUI lists
- `CaseIterable` - Iterate all cases

### DateSuggesting Protocol

Create custom date suggestions:

```swift
struct NextPayday: DateSuggesting {
    func date(onOrAfter: Date, calendar: Calendar) -> Date {
        // Your logic here
    }
}
```

## Documentation

Build DocC documentation:

```bash
swift package generate-documentation --target SuggestedDate
```

## Requirements

- Swift 6.2+
- macOS 26+, iOS 26+, tvOS 26+, watchOS 26+, visionOS 26+

## License

See [LICENSE](LICENSE) for details.
