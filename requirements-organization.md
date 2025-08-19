# Requirements-Based File Organization

## Hierarchy Structure

### Level 1: Dynamometer (Top Level)
- Main app container and navigation

### Level 2: Dashboard, Settings
- Primary functional areas

### Level 3: Third-Level Requirements

#### Dashboard
1. **Data Visualization**
   - Chart rendering and scaling
   - Baseline corridor display
   - Trend line analysis
   - Color-coded data points

2. **Data Entry**
   - Value input validation
   - Date selection
   - Save/submit functionality
   - Keyboard management

3. **Guidance System**
   - Today's reading classification
   - Trend guidance
   - Performance feedback
   - Help and explanations

4. **Recent Activity**
   - Reading history display
   - Classification badges
   - Delete/edit capabilities
   - List management

#### Settings
1. **Baseline Configuration**
   - Corridor min/max values
   - Auto-calculation from recent data
   - Manual adjustment
   - Validation logic

2. **Chart Preferences**
   - SMA window configuration
   - Scale settings
   - Display options
   - Calculation parameters

3. **Data Management**
   - CSV import functionality
   - CSV export functionality
   - File format handling
   - Error management

4. **App Configuration**
   - Default settings initialization
   - Data persistence
   - CloudKit sync settings
   - User preferences

## Proposed File Tree Structure

```
Dynamometer/
├── App/
│   ├── DynamometerApp.swift
│   ├── ContentView.swift
│   └── Theme.swift
├── Dashboard/
│   ├── DashboardView.swift
│   ├── DataVisualization/
│   │   ├── ChartView.swift
│   │   ├── ChartData.swift
│   │   ├── ChartScaling.swift
│   │   └── BaselineRenderer.swift
│   ├── DataEntry/
│   │   ├── ValueInputView.swift
│   │   ├── DatePickerView.swift
│   │   └── InputValidation.swift
│   ├── GuidanceSystem/
│   │   ├── GuidanceView.swift
│   │   ├── GuidanceLogic.swift
│   │   ├── TrendAnalysis.swift
│   │   └── PerformanceFeedback.swift
│   └── RecentActivity/
│       ├── ReadingsList.swift
│       ├── ReadingRow.swift
│       ├── ClassificationBadge.swift
│       └── ListActions.swift
├── Settings/
│   ├── SettingsView.swift
│   ├── BaselineConfiguration/
│   │   ├── BaselineEditor.swift
│   │   ├── AutoCalculation.swift
│   │   └── ValidationLogic.swift
│   ├── ChartPreferences/
│   │   ├── SMAConfiguration.swift
│   │   ├── ScaleSettings.swift
│   │   └── DisplayOptions.swift
│   ├── DataManagement/
│   │   ├── CSVImport.swift
│   │   ├── CSVExport.swift
│   │   ├── FileHandling.swift
│   │   └── ErrorManagement.swift
│   └── AppConfiguration/
│       ├── DefaultSettings.swift
│       ├── PersistenceLayer.swift
│       └── CloudKitSync.swift
├── Models/
│   ├── Reading.swift
│   └── AppSettings.swift
├── Shared/
│   ├── Components/
│   │   └── Pill.swift
│   └── Utilities/
│       └── Extensions.swift
└── Tests/
    ├── DashboardTests/
    ├── SettingsTests/
    └── ModelTests/
```