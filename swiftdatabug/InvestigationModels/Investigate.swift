//
//  Investigate.swift
//  swiftdatabug
//
//  Created by Nils Neuhaus on 09.03.26.
//

import Foundation
import SwiftData
import SwiftUI
import Vision


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
