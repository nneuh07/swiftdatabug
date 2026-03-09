//
//  ProjectDataStack.swift
//  swiftdatabug
//
//  Created by Nils Neuhaus on 20.06.25.
//

import Foundation
import SwiftData

enum ProjectDataStack {
    // Temporary stage-0/1 placeholder. Restore the full production stack once
    // the missing settings, analytics, and handler types are added to this repo.
    static let modelContainer: ModelContainer = {
        let schema = Schema([
            CullingProject.self,
            PhotoAsset.self,
            FileMetaData.self,
            Bookmark.self,
            ExifData.self,
            ImageAnalysis.self,
        ])
        let configuration = ModelConfiguration(
            "ProjectDataStack-Placeholder",
            schema: schema
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: configuration
            )
        } catch {
            fatalError("Failed to create placeholder ProjectDataStack: \(error)")
        }
    }()
}
