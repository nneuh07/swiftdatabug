//
//  InvestigationAssetRow.swift
//  swiftdatabug
//
//  Created by Nils Neuhaus on 09.03.26.
//

import SwiftUI


struct InvestigationAssetRow: View {
    let asset: InvestigationPhotoAsset

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(asset.fileName)
            Text(asset.creationDate.formatted(date: .abbreviated, time: .standard))
                .font(.caption)
                .foregroundStyle(.secondary)

            if let score = asset.imageAnalysis?.overallAestheticsScore {
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
