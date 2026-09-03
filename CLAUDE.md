# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Swift package providing date suggestion utilities for task/reminder due date selection. Two modules:
- `SuggestedDate` — core enum with date calculation logic, conforms to `DateSuggesting` protocol
- `SuggestedDateUI` — SwiftUI `DateSuggestionView` component

## Build & Test

```bash
swift build
swift test
swift package generate-documentation --target SuggestedDate
```

## Key Details

- Swift 6.2+, SPM, platforms: macOS 26+, iOS 26+, tvOS 26+, watchOS 26+, visionOS 26+
- Uses Swift Testing framework (`@Test` macro), not XCTest
- All date calculations must be calendar/timezone-aware — use `Calendar` parameter, never hardcode
- `SuggestedDate` enum is `Sendable` — keep it thread-safe
- CI runs on GitHub Actions (build, test, generate docs) on push/PR to main
