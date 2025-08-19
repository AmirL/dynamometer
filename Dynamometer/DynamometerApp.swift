//
//  DynamometerApp.swift
//  Dynamometer
//
//  Created by Amir on 09.08.2025.
//

import SwiftUI
import SwiftData

@main
struct DynamometerApp: App {
    @Query private var settings: [AppSettings]
    @StateObject private var migrationManager = MigrationManager()
    @State private var modelContainer: ModelContainer?
    @State private var showMigrationAlert = false
    
    private let schema = Schema([
        Reading.self,
        AppSettings.self
    ])

    var body: some Scene {
        WindowGroup {
            Group {
                if let container = modelContainer {
                    ContentView()
                        .preferredColorScheme(colorScheme)
                        .tint(Theme.tint)
                        .modelContainer(container)
                } else {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Theme.backgroundGradient.ignoresSafeArea())
                }
            }
            .sheet(isPresented: $showMigrationAlert) {
                MigrationAlertView(
                    migrationManager: migrationManager,
                    showingAlert: $showMigrationAlert,
                    onRetry: retryMigration,
                    onStartFresh: startFresh
                )
                .interactiveDismissDisabled()
            }
            .task {
                await initializeModelContainer()
            }
        }
    }
    
    private var colorScheme: ColorScheme? {
        guard let appearance = settings.first?.appearance else { return nil }
        
        switch appearance {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
    
    private func initializeModelContainer() async {
        let isUITestInMemory = CommandLine.arguments.contains("UI_TESTS_IN_MEMORY")
        
        do {
            let container = try await migrationManager.createModelContainer(
                schema: schema,
                isInMemory: isUITestInMemory
            )
            await MainActor.run {
                modelContainer = container
            }
        } catch {
            await MainActor.run {
                showMigrationAlert = true
            }
        }
    }
    
    private func retryMigration() {
        Task {
            await initializeModelContainer()
        }
    }
    
    private func startFresh() {
        Task {
            let isUITestInMemory = CommandLine.arguments.contains("UI_TESTS_IN_MEMORY")
            
            do {
                let container = try await migrationManager.deleteExistingStoreAndCreateFresh(
                    schema: schema,
                    isInMemory: isUITestInMemory
                )
                await MainActor.run {
                    modelContainer = container
                }
            } catch {
                print("Failed to create fresh container: \(error)")
            }
        }
    }
}
