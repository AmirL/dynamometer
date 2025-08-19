/** Requirements:
    - File picker UI for CSV import/export
    - Security scoped resource handling
    - Support multiple file encodings (UTF-8, ASCII)
    - Generate descriptive filenames for exports
*/

import SwiftUI
import UniformTypeIdentifiers

struct FileHandling {
    static func importButton(
        isPresented: Binding<Bool>,
        onImport: @escaping (URL) -> Void,
        onError: @escaping (Error) -> Void
    ) -> some View {
        Button {
            isPresented.wrappedValue = true
        } label: {
            Label("Import CSV", systemImage: "square.and.arrow.down")
        }
        .buttonStyle(.bordered)
        .tint(Theme.tint)
        .fileImporter(
            isPresented: isPresented,
            allowedContentTypes: [UTType.commaSeparatedText, .plainText]
        ) { result in
            switch result {
            case .success(let url):
                onImport(url)
            case .failure(let error):
                onError(error)
            }
        }
    }
    
    static func exportButton(
        isPresented: Binding<Bool>,
        csvContent: String,
        onComplete: @escaping (Result<URL, Error>) -> Void
    ) -> some View {
        Button {
            isPresented.wrappedValue = true
        } label: {
            Label("Export CSV", systemImage: "square.and.arrow.up")
        }
        .buttonStyle(.bordered)
        .tint(Theme.tint)
        .fileExporter(
            isPresented: isPresented,
            document: CSVDocument(text: csvContent),
            contentType: .commaSeparatedText,
            defaultFilename: "DynamometerReadings"
        ) { result in
            onComplete(result)
        }
    }
    
    static func readFileContent(from url: URL) throws -> String {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        
        // Try UTF-8 first, then ASCII
        if let text = String(data: data, encoding: .utf8) {
            return text
        } else if let text = String(data: data, encoding: .ascii) {
            return text
        } else {
            throw FileError.unsupportedEncoding
        }
    }
}

enum FileError: LocalizedError {
    case unsupportedEncoding
    
    var errorDescription: String? {
        switch self {
        case .unsupportedEncoding:
            return "Unsupported file encoding"
        }
    }
}