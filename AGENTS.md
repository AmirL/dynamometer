# Repository Guidelines

## Project Structure & Module Organization
- `Dynamometer/`: SwiftUI app sources (`DynamometerApp.swift`, `ContentView.swift`, models like `Item.swift`, `Info.plist`, `Dynamometer.entitlements`, and `Assets.xcassets`).
- `DynamometerTests/`: XCTest unit tests (e.g., `DynamometerTests.swift`).
- `DynamometerUITests/`: XCUITest UI tests (`DynamometerUITests.swift`, launch tests).
- `Dynamometer.xcodeproj/`: Xcode project and workspace metadata.

## Build, Test, and Development Commands
- Open in Xcode: `open Dynamometer.xcodeproj`
- List schemes/destinations: `xcodebuild -list -project Dynamometer.xcodeproj` and `xcodebuild -showdestinations -scheme Dynamometer`
- Build (Simulator): `xcodebuild -scheme Dynamometer -sdk iphonesimulator build`
- Run tests (CLI): `xcodebuild test -scheme Dynamometer -destination 'platform=iOS Simulator,name=iPhone 15'`
- Run tests (Xcode): Product > Test or `Cmd+U`.

## Coding Style & Naming Conventions
- Indentation: 2 spaces; keep lines focused and readable.
- Swift naming: Types/Enums `PascalCase`; properties/functions `camelCase`.
- Files: One primary type per file; filename matches type (e.g., `Item.swift`).
- SwiftUI: Keep `ContentView` lean; extract logic to small views or view models when added.
- Formatting: Use Xcode’s default formatter; no linters configured yet.

## Testing Guidelines
- Frameworks: XCTest for unit tests, XCUITest for UI.
- Location: Unit tests in `DynamometerTests/`; UI tests in `DynamometerUITests/`.
- Naming: Methods start with `test...`; test files end with `...Tests.swift`.
- Running: Prefer fast unit tests; avoid external I/O. Use the `xcodebuild test` command above for CI/local checks.

## Commit & Pull Request Guidelines
- Commits: Imperative mood, concise subject (≤72 chars). Example: `Add item model and list view`.
- References: Link issues (e.g., `Fixes #42`). Group related changes.
- PRs: Include summary, rationale, steps to test, and screenshots for UI changes. Ensure tests pass and the app builds for Simulator.

## Security & Configuration Tips
- Entitlements: Document any changes in `Dynamometer.entitlements` and why the capability is required.
- Secrets: Do not hardcode credentials. Prefer Keychain or secure storage; keep configuration in non-sensitive plists only.
