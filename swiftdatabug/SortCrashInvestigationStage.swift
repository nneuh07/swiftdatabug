//
//  SortCrashInvestigationStage.swift
//  swiftdatabug
//
//  Created by Nils Neuhaus on 09.03.26.
//

import Foundation
import SwiftData
import SwiftUI
import Vision

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
            InvestigationCullingProject.self,
            InvestigationPhotoAsset.self,
            InvestigationFileMetaData.self,
            InvestigationBookmark.self,
            InvestigationExifData.self,
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
            .appendingPathComponent("ReducedModels")
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
    static let projectName = "Test Project"
    static let filteredCameraModel = "Canon R5"
    static let filteredStatusRaw = 0
    static let baseDate = Date(timeIntervalSince1970: 1_700_000_000)
    static let samples: [InvestigationSample] = [
        InvestigationSample(
            fileName: "IMG_001.jpg",
            creationOffset: 0,
            cameraModel: "Canon R5",
            statusRaw: 0,
            score: 0.92
        ),
        InvestigationSample(
            fileName: "IMG_002.jpg",
            creationOffset: 1,
            cameraModel: "Sony A7",
            statusRaw: 0,
            score: 0.45
        ),
        InvestigationSample(
            fileName: "IMG_003.jpg",
            creationOffset: 2,
            cameraModel: "Canon R5",
            statusRaw: 0,
            score: 0.78
        ),
        InvestigationSample(
            fileName: "IMG_004.jpg",
            creationOffset: 3,
            cameraModel: "Sony A7",
            statusRaw: 0,
            score: nil
        ),
        InvestigationSample(
            fileName: "IMG_005.jpg",
            creationOffset: 4,
            cameraModel: "Canon R5",
            statusRaw: 1,
            score: 0.11
        ),
    ]
}

private struct InvestigationSample {
    let fileName: String
    let creationOffset: TimeInterval
    let cameraModel: String
    let statusRaw: Int
    let score: Double?
}

private enum InvestigationSortBy: String, CaseIterable, Identifiable {
    case date = "Date"
    case quality = "Quality"

    var id: Self { self }
}

private struct SortCrashInvestigationView: View {
    @State private var sortBy: InvestigationSortBy = .date

    var body: some View {
        NavigationStack {
            InvestigationProjectGate(sortBy: sortBy)
                .navigationTitle("Sort Crash Investigation")
                .safeAreaInset(edge: .top) {
                    InvestigationControls(sortBy: $sortBy)
                }
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

private struct InvestigationProjectGate: View {
    @Query private var projects: [InvestigationCullingProject]
    @Environment(\.modelContext) private var context

    let sortBy: InvestigationSortBy

    var body: some View {
        Group {
            if let project = projects.first {
                InvestigationAssetListView(
                    request: InvestigationPhotoAssetRequest(
                        projectId: project.id,
                        sortBy: sortBy
                    )
                )
            } else {
                ProgressView("Setting up reduced-model sample data...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            insertInvestigationSampleData(into: context)
        }
    }
}

private struct InvestigationAssetListView: View {
    @Query private var assets: [InvestigationPhotoAsset]

    init(request: InvestigationPhotoAssetRequest) {
        _assets = Query(
            filter: request.filterPredicate(),
            sort: request.sortDescriptors()
        )
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
    let cameraModel: String?
    let score: Double?
}

private struct InvestigationAssetRow: View {
    let asset: InvestigationAssetRowData

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(asset.fileName)
            Text(asset.cameraModel ?? "No camera")
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

private struct InvestigationPhotoAssetRequest {
    let projectId: UUID
    let sortBy: InvestigationSortBy

    func filterPredicate() -> Predicate<InvestigationPhotoAsset> {
        let basePredicate = #Predicate<InvestigationPhotoAsset> { asset in
            asset.cullingProject?.id == projectId
        }

        let statusValues = [InvestigationFixture.filteredStatusRaw]
        let statusPredicate = #Predicate<InvestigationPhotoAsset> { asset in
            statusValues.contains(asset.statusRaw)
        }

        let cameraValues = [InvestigationFixture.filteredCameraModel]
        let cameraPredicate = #Predicate<InvestigationPhotoAsset> { asset in
            asset.exifData?.cameraModel.flatMap { cameraModel in
                cameraValues.contains(cameraModel) ? true : nil
            } ?? false
        }

        return #Predicate<InvestigationPhotoAsset> { asset in
            basePredicate.evaluate(asset)
                && statusPredicate.evaluate(asset)
                && cameraPredicate.evaluate(asset)
        }
    }

    func sortDescriptors() -> [SortDescriptor<InvestigationPhotoAsset>] {
        switch sortBy {
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

private extension InvestigationPhotoAsset {
    var rowData: InvestigationAssetRowData {
        InvestigationAssetRowData(
            id: id,
            fileName: metadata.fileName,
            cameraModel: exifData?.cameraModel,
            score: imageAnalysis?.overallAestheticsScore
        )
    }
}

private func insertInvestigationSampleData(into context: ModelContext) {
    let existing = try? context.fetch(FetchDescriptor<InvestigationCullingProject>())
    guard existing?.isEmpty ?? true else { return }

    let project = InvestigationCullingProject(name: InvestigationFixture.projectName)
    context.insert(project)

    for sample in InvestigationFixture.samples {
        let analysis = sample.score.map {
            InvestigationImageAnalysis(overallAestheticsScore: $0)
        }
        let asset = InvestigationPhotoAsset(
            fileName: sample.fileName,
            cullingProject: project,
            imageAnalysis: analysis
        )

        asset.creationDate = InvestigationFixture.baseDate.addingTimeInterval(
            sample.creationOffset
        )
        asset.modifiedDate = asset.creationDate
        asset.statusRaw = sample.statusRaw
        asset.exifData = InvestigationExifData(cameraModel: sample.cameraModel)
        analysis?.photoAsset = asset

        context.insert(asset)
    }

    try? context.save()
}

@Model
final class InvestigationBookmark {
    @Attribute var url: URL
    @Attribute var bookmark: Data

    init(url: URL, bookmark: Data = Data()) {
        self.url = url
        self.bookmark = bookmark
    }
}

@Model
final class InvestigationFileMetaData {
    @Relationship(deleteRule: .cascade) var fileBookmark: InvestigationBookmark
    @Relationship(deleteRule: .cascade) var directoryBookmark: InvestigationBookmark
    @Attribute var fileName: String
    @Attribute var fileExtension: String
    @Attribute var baseName: String
    @Attribute var fileSize: Int64

    init(fileName: String, fileExtension: String) {
        let dummyURL = URL(fileURLWithPath: "/tmp/\(fileName)")
        self.fileBookmark = InvestigationBookmark(url: dummyURL)
        self.directoryBookmark = InvestigationBookmark(
            url: URL(fileURLWithPath: "/tmp")
        )
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.baseName = fileName
        self.fileSize = 0
    }
}

@Model
final class InvestigationExifData {
    @Attribute var cameraModel: String?

    init(cameraModel: String? = nil) {
        self.cameraModel = cameraModel
    }
}

@Model
final class InvestigationImageAnalysis {
    @Attribute var overallAestheticsScore: Double
    @Attribute var isUtility: Bool
    @Attribute var featurePrints: [FeaturePrintObservation]?

    var photoAsset: InvestigationPhotoAsset?

    init(
        overallAestheticsScore: Double,
        isUtility: Bool = false,
        featurePrint: FeaturePrintObservation? = nil
    ) {
        self.overallAestheticsScore = overallAestheticsScore
        self.isUtility = isUtility
        self.featurePrints = featurePrint.map { [$0] } ?? []
    }
}

@Model
final class InvestigationCullingProject {
    @Attribute(.unique) var id: UUID = UUID()
    @Attribute var name: String

    init(name: String) {
        self.name = name
    }
}

@Model
final class InvestigationPhotoAsset {
    @Attribute(.unique) var id: UUID = UUID()
    @Relationship(deleteRule: .cascade) var metadata: InvestigationFileMetaData
    @Attribute var creationDate: Date = Date()
    @Attribute var modifiedDate: Date = Date()
    @Attribute var starRating: Int = 0
    @Attribute var statusRaw: Int = 0

    @Relationship(deleteRule: .cascade) var exifData: InvestigationExifData?
    @Relationship(deleteRule: .cascade)
    var imageAnalysis: InvestigationImageAnalysis?
    var cullingProject: InvestigationCullingProject?

    init(
        fileName: String,
        cullingProject: InvestigationCullingProject,
        imageAnalysis: InvestigationImageAnalysis? = nil
    ) {
        self.metadata = InvestigationFileMetaData(
            fileName: fileName,
            fileExtension: "jpg"
        )
        self.cullingProject = cullingProject
        self.imageAnalysis = imageAnalysis
    }
}
