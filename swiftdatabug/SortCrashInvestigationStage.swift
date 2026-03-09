//
//  SortCrashInvestigationStage.swift
//  swiftdatabug
//
//  Created by Nils Neuhaus on 09.03.26.
//

import Foundation
import SwiftData
import SwiftUI


struct InvestigationAssetListView: View {
    @Query private var assets: [InvestigationPhotoAsset]

    init(sortBy: InvestigationSortBy) {
        _assets = Query(sort: sortBy.sortDescriptors)
    }

    var body: some View {
        List(assets) { asset in
            InvestigationAssetRow(asset: asset)
        }
    }
}
