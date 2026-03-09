//
//  SortCrashInvestigationView.swift
//  swiftdatabug
//
//  Created by Nils Neuhaus on 09.03.26.
//

import SwiftUI
import SwiftData


struct SortCrashInvestigationView: View {
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

func insertInvestigationSampleData(into context: ModelContext) {
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
