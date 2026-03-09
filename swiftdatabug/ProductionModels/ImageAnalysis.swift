import Foundation
import SwiftData
import Vision

@Model
final class ImageAnalysis {
    @Attribute var overallAestheticsScore: Double
    @Attribute var isUtility: Bool
    @Attribute var featurePrints: [FeaturePrintObservation]?

    var photoAsset: PhotoAsset?

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
