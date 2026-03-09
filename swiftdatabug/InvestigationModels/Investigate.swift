//
//  Investigate.swift
//  swiftdatabug
//
//  Created by Nils Neuhaus on 09.03.26.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: Comment in for crash on release

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
