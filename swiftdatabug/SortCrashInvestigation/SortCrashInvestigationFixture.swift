import Foundation

enum InvestigationFixture {
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

struct InvestigationSample {
    let fileName: String
    let creationOffset: TimeInterval
    let score: Double?
}
