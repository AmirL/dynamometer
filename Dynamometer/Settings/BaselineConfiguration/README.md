# BaselineConfiguration Module

## Requirements
Manages baseline corridor values with manual editing and automatic calculation.

## Components
- **BaselineEditor**: UI for editing min/max baseline values with validation
- **AutoCalculation**: Calculate baseline from recent readings (median ± 5%) and default values
- **ValidationLogic**: Ensure min ≤ max and reasonable value ranges