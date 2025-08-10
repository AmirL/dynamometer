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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Reading.self,
            AppSettings.self
        ])
        // Use in-memory store when running UI tests for determinism
        let isUITestInMemory = CommandLine.arguments.contains("UI_TESTS_IN_MEMORY")
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isUITestInMemory)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // If migration fails, delete the store and create fresh
            print("Migration failed, deleting store and creating fresh: \(error)")
            
            // Delete existing store files
            let url = URL.applicationSupportDirectory.appending(path: "default.store")
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(at: url.appendingPathExtension("wal"))
            try? FileManager.default.removeItem(at: url.appendingPathExtension("shm"))
            
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer even with fresh start: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .tint(Theme.tint)
        }
        .modelContainer(sharedModelContainer)
    }
}
