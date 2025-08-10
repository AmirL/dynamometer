# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dynamometer is a SwiftUI iOS app for tracking grip strength measurements using a hand dynamometer. The app provides logging, visualization, and data import capabilities.

## Architecture

**SwiftData Models (Item.swift:11-31)**:
- `Reading`: Core data model storing date and grip strength value
- `AppSettings`: Baseline configuration for corridor min/max values

**Views**:
- `ContentView`: Main TabView container with three tabs
- `LogView`: Data entry form with recent readings list and classification
- `ChartView`: Swift Charts visualization with baseline corridor and colored points
- `SettingsView`: Baseline configuration and CSV import functionality

**Data Import**:
- `CSVImport`: Flexible CSV parser supporting multiple date formats and column orders

## Build Commands

This is an Xcode project. Use standard Xcode build commands:
- Build: `xcodebuild -project Dynamometer.xcodeproj -scheme Dynamometer build`
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