import Foundation
import SwiftData

enum SortCrashInvestigationConfig {
    static let resetStoreOnLaunch = true
}

@MainActor
enum SortCrashInvestigationDataStack {
    private static var cachedContainer: ModelContainer?
    private static var resetPerformed = false

    static func container() -> ModelContainer {
        if let cachedContainer {
            return cachedContainer
        }

        let storeURL = storeURL()

        if SortCrashInvestigationConfig.resetStoreOnLaunch && !resetPerformed {
            resetStore(at: storeURL)
            resetPerformed = true
        }

        let schema = Schema([
            InvestigationPhotoAsset.self,
            InvestigationImageAnalysis.self,
        ])

        let configuration = ModelConfiguration(
            "SortCrashInvestigation",
            schema: schema,
            url: storeURL
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: configuration
            )
            cachedContainer = container
            return container
        } catch {
            fatalError("Failed to create investigation container: \(error)")
        }
    }

    private static func storeURL() -> URL {
        let rootDirectory = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!.appendingPathComponent(
            "SortCrashInvestigation",
            isDirectory: true
        )

        try? FileManager.default.createDirectory(
            at: rootDirectory,
            withIntermediateDirectories: true
        )

        return rootDirectory
            .appendingPathComponent("MinimalRepro")
            .appendingPathExtension("store")
    }

    private static func resetStore(at url: URL) {
        let candidateURLs = [
            url,
            URL(fileURLWithPath: url.path + "-shm"),
            URL(fileURLWithPath: url.path + "-wal"),
        ]

        for candidateURL in candidateURLs
        where FileManager.default.fileExists(atPath: candidateURL.path) {
            try? FileManager.default.removeItem(at: candidateURL)
        }
    }
}
