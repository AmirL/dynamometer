# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dynamometer is a SwiftUI iOS app for tracking grip strength measurements using a hand dynamometer. The app provides logging, visualization, and data import capabilities.

## Code Organization & Design Approach

### Requirements-Based File Structure
- Organize files by functional requirements, not technical categories
- Structure: `Level1/Level2/Level3/` where each level represents user-facing features
- Example: `Dashboard/DataEntry/` contains all data input related files
- Each directory has a `README.md` with high-level requirements overview

### File Requirements Format
Every Swift file must start with requirements in this format:
```swift
/** Requirements:
    - Brief, human-readable description of what this does
    - Focus on user-facing behavior, not implementation  
    - Keep bullet points conversational and short
*/
```

Examples:
- Good: "Parse decimals with comma or dot"
- Avoid: "Validation logic for input fields ensuring data integrity"

### Module Structure
- Each functional area gets its own module directory
- Include README.md with module overview and component list
- Break complex features into focused, single-responsibility files
- Use descriptive, requirement-based file names


## Build Commands

This is an Xcode project. Use these build commands:
- Build/Lint: `xcodebuild -project Dynamometer.xcodeproj -scheme Dynamometer -destination "platform=iOS,name=iPhone Amir" build`
- Test: `xcodebuild -project Dynamometer.xcodeproj -scheme Dynamometer test`
- Archive: `xcodebuild -project Dynamometer.xcodeproj -scheme Dynamometer archive`

## Development Notes

- Swift 5.0, iOS 18.5+ target
- Uses SwiftData for persistence with CloudKit sync capability
- Charts framework for data visualization
- File import uses UniformTypeIdentifiers for CSV files
- Model container configured in DynamometerApp.swift:13-27 with CloudKit support

## Key Features

- Grip strength logging with date picker
- Visual trend analysis with baseline corridor
- Color-coded readings (red=below, green=above, gray=baseline)
- CSV import with flexible parsing
- Automatic baseline recalculation from recent data
- Build app only to my connected device
- When you need to run or build app, do it for my physical iPhone that connected to xcode.