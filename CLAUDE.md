# SuggestedDate

Swift package providing date suggestion utilities for task/reminder due date selection.

## Structure

- `SuggestedDate` - Core library with `SuggestedDate` enum and `DateSuggesting` protocol
- `SuggestedDateUI` - SwiftUI views (currently `DateSuggestionView`)

## Build & Test

```bash
swift build
swift test
swift package generate-documentation --target SuggestedDate
```

## Key Components

- `SuggestedDate` enum: today, tomorrow, nextWorkingDay, nextWeek
- `DateSuggesting` protocol: compute suggested dates
- Conformances: Codable, Sendable, Hashable, Identifiable, CaseIterable

## Requirements

- Swift 6.2+
- macOS 26+, iOS 26+, tvOS 26+, watchOS 26+, visionOS 26+
