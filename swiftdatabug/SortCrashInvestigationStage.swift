//
//  SortCrashInvestigationStage.swift
//  swiftdatabug
//
//  Created by Nils Neuhaus on 09.03.26.
//

import Foundation
import SwiftData
import SwiftUI

enum InvestigationSortBy: String, CaseIterable, Identifiable {
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

struct InvestigationAssetListView: View {
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
