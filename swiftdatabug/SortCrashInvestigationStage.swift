//
//  SortCrashInvestigationStage.swift
//  swiftdatabug
//
//  Created by Nils Neuhaus on 09.03.26.
//

import Foundation
import SwiftData
import SwiftUI

enum SortCrashInvestigationConfig {
    static let resetStoreOnLaunch = true
}

struct SortCrashInvestigationRootView: View {
    var body: some View {
        InvestigationContainerView(
            container: SortCrashInvestigationDataStack.container()
        ) {
            SortCrashInvestigationView()
        }
    }
}

private struct InvestigationContainerView<Content: View>: View {
    let container: ModelContainer
    let content: Content

    init(
        container: ModelContainer,
        @ViewBuilder content: () -> Content
    ) {
        self.container = container
        self.content = content()
    }

    var body: some View {
        content.modelContainer(container)
    }
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

private enum InvestigationFixture {
    static let baseDate = Date(timeIntervalSince1970: 1_700_000_000)
    static let samples: [InvestigationSample] = [
        InvestigationSample(
            fileName: "IMG_001.jpg",
            creationOffset: 0,
            score: 0.92
        ),
        InvestigationSample(
            fileName: "IMG_002.jpg",
            creationOffset: 1,
            score: 0.45
        ),
        InvestigationSample(
            fileName: "IMG_003.jpg",
            creationOffset: 2,
            score: 0.78
        ),
        InvestigationSample(
            fileName: "IMG_004.jpg",
            creationOffset: 3,
            score: nil
        ),
        InvestigationSample(
            fileName: "IMG_005.jpg",
            creationOffset: 4,
            score: 0.11
        ),
    ]
}

private struct InvestigationSample {
    let fileName: String
    let creationOffset: TimeInterval
    let score: Double?
}

private enum InvestigationSortBy: String, CaseIterable, Identifiable {
    case date = "Date"
    case quality = "Quality"

    var id: Self { self }

    var sortDescriptors: [SortDescriptor<InvestigationPhotoAsset>] {
        switch self {
        case .date:
            return [SortDescriptor(\.creationDate, order: .reverse)]
        case .quality:
            return [
                SortDescriptor(
                    \.imageAnalysis?.overallAestheticsScore,
                    order: .reverse
                ),
                SortDescriptor(\.creationDate, order: .reverse),
            ]
        }
    }
}

private struct SortCrashInvestigationView: View {
    @Environment(\.modelContext) private var context
    @State private var sortBy: InvestigationSortBy = .date

    var body: some View {
        NavigationStack {
            InvestigationAssetListView(sortBy: sortBy)
                .navigationTitle("Sort Crash Investigation")
                .safeAreaInset(edge: .top) {
                    InvestigationControls(sortBy: $sortBy)
                }
        }
        .task {
            insertInvestigationSampleData(into: context)
        }
    }
}

private struct InvestigationControls: View {
    @Binding var sortBy: InvestigationSortBy

    var body: some View {
        Picker("Sort By", selection: $sortBy) {
            ForEach(InvestigationSortBy.allCases) { sort in
                Text(sort.rawValue).tag(sort)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.bar)
    }
}

private struct InvestigationAssetListView: View {
    @Query private var assets: [InvestigationPhotoAsset]

    init(sortBy: InvestigationSortBy) {
        _assets = Query(sort: sortBy.sortDescriptors)
    }

    var body: some View {
        List(assets.map(\.rowData)) { asset in
            InvestigationAssetRow(asset: asset)
        }
    }
}

private struct InvestigationAssetRowData: Identifiable {
    let id: UUID
    let fileName: String
    let creationDate: Date
    let score: Double?
}

private struct InvestigationAssetRow: View {
    let asset: InvestigationAssetRowData

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(asset.fileName)
            Text(asset.creationDate.formatted(date: .abbreviated, time: .standard))
                .font(.caption)
                .foregroundStyle(.secondary)

            if let score = asset.score {
                Text(
                    "Aesthetics: \(score, format: .number.precision(.fractionLength(2)))"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            } else {
                Text("No analysis")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private extension InvestigationPhotoAsset {
    var rowData: InvestigationAssetRowData {
        InvestigationAssetRowData(
            id: id,
            fileName: fileName,
            creationDate: creationDate,
            score: imageAnalysis?.overallAestheticsScore
        )
    }
}

private func insertInvestigationSampleData(into context: ModelContext) {
    let existing = try? context.fetch(FetchDescriptor<InvestigationPhotoAsset>())
    guard existing?.isEmpty ?? true else { return }

    for sample in InvestigationFixture.samples {
        let analysis = sample.score.map {
            InvestigationImageAnalysis(overallAestheticsScore: $0)
        }
        let asset = InvestigationPhotoAsset(
            fileName: sample.fileName,
            creationDate: InvestigationFixture.baseDate.addingTimeInterval(
                sample.creationOffset
            ),
            imageAnalysis: analysis
        )

        context.insert(asset)
    }

    try? context.save()
}

// MARK: Comment out for crash on release

@Model
final class InvestigationPhotoAsset {
    @Attribute(.unique) var id: UUID
    @Attribute var fileName: String
    @Attribute var creationDate: Date
    @Relationship(deleteRule: .cascade)
    var imageAnalysis: InvestigationImageAnalysis?

    init(
        id: UUID = UUID(),
        fileName: String,
        creationDate: Date,
        imageAnalysis: InvestigationImageAnalysis? = nil
    ) {
        self.id = id
        self.fileName = fileName
        self.creationDate = creationDate
        self.imageAnalysis = imageAnalysis
    }
}

@Model
final class InvestigationImageAnalysis {
    @Attribute var overallAestheticsScore: Double

    init(overallAestheticsScore: Double) {
        self.overallAestheticsScore = overallAestheticsScore
    }
}
