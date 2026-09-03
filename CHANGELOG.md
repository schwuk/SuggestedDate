# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-09-03

### Added

- `base` parameter on `DateSuggestionView` to control the suggestion list (defaults to `coreSuggestions`)

## [2.0.0] - 2026-09-03

### Added

- `inOneWeek` and `inTwoWeeks` cases
- `extendedSuggestions` — `coreSuggestions` plus the fixed-offset cases
- `base` parameter on `suggestions(for:calendar:base:)` to control the starting list (defaults to `coreSuggestions`)

### Changed

- `defaultSuggestions` renamed to `coreSuggestions`
- Documentation overhaul: per-case docs, fixed symbol links, DocC Topics, day-granularity contract clarified on `DateSuggesting`
- Added `swift format` configuration; swift-docc-plugin 1.4.3 → 1.5.0

### Removed

- **Breaking**: `startOfDay(for:calendar:)` — use `Calendar.startOfDay(for:)` instead

## [1.1.0] - 2026-03-23

### Added

- `endOfThisWeek` and `endOfNextWeek` cases
- `SuggestedDate.suggestions(for:calendar:)` for contextual suggestions including deadlines
- `isDeadline` property
- `onSuggestionSelected` callback on `DateSuggestionView`

## [1.0.0] - 2025-11-19

### Added

- `SuggestedDate` enum with cases: `today`, `tomorrow`, `nextWorkingDay`, `nextWeek`
- `DateSuggesting` protocol for custom date suggestions
- Protocol conformances: `Codable`, `Sendable`, `Hashable`, `Identifiable`, `CaseIterable`
- Multi-platform support: macOS, iOS, tvOS, watchOS, visionOS
- DocC documentation
- GitHub Actions CI workflow
