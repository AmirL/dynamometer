# Dynamometer App Documentation

This directory contains detailed module documentation for the Dynamometer iOS app.

## Module Documentation

### Dashboard
- [Chart](modules/Dashboard/Chart/README.md) - Data visualization with trend analysis and baseline corridor
- [DataEntry](modules/Dashboard/DataEntry/README.md) - User input for new grip strength readings
- [GuidanceSystem](modules/Dashboard/GuidanceSystem/README.md) - Performance feedback and trend analysis
- [RecentActivity](modules/Dashboard/RecentActivity/README.md) - Recent readings list with classifications

### Settings
- [AppConfiguration](modules/Settings/AppConfiguration/README.md) - Core app settings and CloudKit sync
- [BaselineConfiguration](modules/Settings/BaselineConfiguration/README.md) - Baseline corridor management
- [ChartPreferences](modules/Settings/ChartPreferences/README.md) - Chart display configuration
- [DataManagement](modules/Settings/DataManagement/README.md) - CSV import/export operations

### Shared
- [Shared](modules/Shared/README.md) - Common utilities and themes

## Architecture

The app follows a requirements-based file structure where files are organized by functional requirements rather than technical categories. Each module contains components focused on specific user-facing features.