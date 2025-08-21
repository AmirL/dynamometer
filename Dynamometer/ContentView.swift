//
//  ContentView.swift
//  Dynamometer
//
//  Updated for logging and charting dynamometer readings.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var systemColorScheme
    @Query private var settings: [AppSettings]
    @Query private var readings: [Reading]

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            TabView {
                DashboardView()
                    .tabItem { Label("Chart", systemImage: "chart.xyaxis.line") }

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "slider.horizontal.3") }
            }
        }
        .preferredColorScheme(colorScheme)
        .onAppear {
            ensureSettings()
            seedUITestDataIfNeeded()
        }
    }
    
    private var colorScheme: ColorScheme? {
        guard let firstSetting = settings.first else { 
            return nil 
        }
        
        let appearance = firstSetting.appearance
        
        switch appearance {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            // Return nil to let system decide, but we'll handle the update differently
            return nil
        }
    }

    private func ensureSettings() {
        if settings.isEmpty {
            modelContext.insert(AppSettings())
            try? modelContext.save()
        }
    }

    private func seedUITestDataIfNeeded() {
        guard CommandLine.arguments.contains("UI_TESTS_SEED_DATA") else { return }
        guard readings.isEmpty else { return }

        let cal = Calendar.current
        let start = cal.date(byAdding: .day, value: -100, to: Date()) ?? Date()
        for i in 0..<100 {
            if let d = cal.date(byAdding: .day, value: i, to: start) {
                let base: Double = 45
                let seasonal = sin(Double(i) / 30.0) * 5.0
                let noise = Double((i * 31) % 7) - 3.0
                let value = base + seasonal + noise
                modelContext.insert(Reading(date: d, value: value))
            }
        }
        try? modelContext.save()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Reading.self, AppSettings.self], inMemory: true)
}
