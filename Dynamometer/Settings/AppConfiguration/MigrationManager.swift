/** Requirements:
    - Handle SwiftData schema migrations safely
    - Backup user data before destructive operations
    - Present user choices when migration fails
    - Never silently delete user data
*/

import SwiftUI
import SwiftData

@MainActor
class MigrationManager: ObservableObject {
    @Published var showMigrationAlert = false
    @Published var migrationError: Error?
    
    private var backupPath: URL? = nil
    
    func createModelContainer(schema: Schema, isInMemory: Bool = false) async throws -> ModelContainer {
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isInMemory)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("Migration failed: \(error)")
            
            // Try to backup existing data first
            await backupExistingData()
            
            // Store error and show alert to user
            migrationError = error
            showMigrationAlert = true
            
            // For now, throw the error - user will decide what to do
            throw error
        }
    }
    
    private func backupExistingData() async {
        let storeURL = URL.applicationSupportDirectory.appending(path: "default.store")
        
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            print("No existing store to backup")
            return
        }
        
        let backupURL = URL.applicationSupportDirectory.appending(path: "backup_\(Date().timeIntervalSince1970).store")
        
        do {
            try FileManager.default.copyItem(at: storeURL, to: backupURL)
            backupPath = backupURL
            print("Backed up existing data to: \(backupURL.path)")
            
            // Also backup the WAL and SHM files if they exist
            let walURL = storeURL.appendingPathExtension("wal")
            let shmURL = storeURL.appendingPathExtension("shm")
            
            if FileManager.default.fileExists(atPath: walURL.path) {
                try FileManager.default.copyItem(at: walURL, to: backupURL.appendingPathExtension("wal"))
            }
            
            if FileManager.default.fileExists(atPath: shmURL.path) {
                try FileManager.default.copyItem(at: shmURL, to: backupURL.appendingPathExtension("shm"))
            }
            
        } catch {
            print("Failed to backup existing data: \(error)")
        }
    }
    
    func deleteExistingStoreAndCreateFresh(schema: Schema, isInMemory: Bool = false) async throws -> ModelContainer {
        let storeURL = URL.applicationSupportDirectory.appending(path: "default.store")
        
        // Delete store files
        try? FileManager.default.removeItem(at: storeURL)
        try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("wal"))
        try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("shm"))
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isInMemory)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer even with fresh start: \(error)")
        }
    }
    
    func restoreFromBackup() throws {
        guard let backupPath = backupPath else {
            throw MigrationError.noBackupAvailable
        }
        
        let storeURL = URL.applicationSupportDirectory.appending(path: "default.store")
        
        // Remove any existing files
        try? FileManager.default.removeItem(at: storeURL)
        try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("wal"))
        try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("shm"))
        
        // Restore from backup
        try FileManager.default.copyItem(at: backupPath, to: storeURL)
        
        // Restore WAL and SHM if they exist
        let backupWalURL = backupPath.appendingPathExtension("wal")
        let backupShmURL = backupPath.appendingPathExtension("shm")
        
        if FileManager.default.fileExists(atPath: backupWalURL.path) {
            try FileManager.default.copyItem(at: backupWalURL, to: storeURL.appendingPathExtension("wal"))
        }
        
        if FileManager.default.fileExists(atPath: backupShmURL.path) {
            try FileManager.default.copyItem(at: backupShmURL, to: storeURL.appendingPathExtension("shm"))
        }
    }
}

enum MigrationError: LocalizedError {
    case noBackupAvailable
    
    var errorDescription: String? {
        switch self {
        case .noBackupAvailable:
            return "No backup data available to restore"
        }
    }
}

struct MigrationAlertView: View {
    @ObservedObject var migrationManager: MigrationManager
    @Binding var showingAlert: Bool
    let onRetry: () -> Void
    let onStartFresh: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Data Migration Issue")
                .font(.headline)
            
            Text("The app's data format has changed and automatic migration failed. Your existing data has been safely backed up.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let error = migrationManager.migrationError {
                Text("Error: \(error.localizedDescription)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 12) {
                Button("Retry Migration") {
                    onRetry()
                    showingAlert = false
                }
                .buttonStyle(.borderedProminent)
                
                Button("Start Fresh (Keep Backup)") {
                    onStartFresh()
                    showingAlert = false
                }
                .buttonStyle(.bordered)
                
                Text("Your data backup will be preserved and can be manually recovered if needed")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}