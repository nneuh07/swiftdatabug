import SwiftData
import SwiftUI
import UIKit

struct ImageCacheKey: Hashable {
    let key: String
    let folder: String
}

enum PhotoOrientation {
    case vertical
    case horizontal
}

extension Image.Orientation {
    var displayOrientation: PhotoOrientation {
        switch self {
        case .left, .leftMirrored, .right, .rightMirrored:
            return .horizontal
        default:
            return .vertical
        }
    }
}

@Model
final class PhotoAsset: Identifiable {
    @Attribute(.unique) var id: UUID
    @Relationship(deleteRule: .cascade) var metadata: FileMetaData
    @Attribute var creationDate: Date
    @Attribute var modifiedDate: Date
    @Attribute var starRating: Int
    @Attribute var statusRaw: Int
    @Relationship(deleteRule: .cascade) var exifData: ExifData?
    @Relationship(deleteRule: .cascade) var imageAnalysis: ImageAnalysis?
    var cullingProject: CullingProject? = nil

    // Temporary investigation stubs to keep the wider app compiling while
    // reducing the persisted PhotoAsset schema toward the standalone repro.
    var gpsLocation: Coordinate? {
        get { nil }
        set { }
    }
    var photoGroups: [PhotoGroup] {
        get { [] }
        set { }
    }

    var status: CullingStatus {
        get { CullingStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }
    var orientation: Image.Orientation {
        get { .up }
        set { }
    }
    
    var displayOrientation: PhotoOrientation {
        return orientation.displayOrientation
    }

    var thumbnailCacheKey: ImageCacheKey {
        return ImageCacheKey(
            key: id.uuidString,
            folder: cullingProject?.id.uuidString ?? "default"
        )
    }

    init(
        id: UUID = UUID(),
        metadata: FileMetaData,
        creationDate: Date,
        gpsLocation: Coordinate? = nil,
        starRating: Int = 0,
        status: CullingStatus = .pending,
        orientation: Image.Orientation = .up,
        exifData: ExifData? = nil,
        imageAnalysis: ImageAnalysis? = nil,
        photoGroups: [PhotoGroup] = [],
        cullingProject: CullingProject
    ) {
        self.id = id
        self.metadata = metadata
        self.creationDate = creationDate
        self.modifiedDate = creationDate
        self.starRating = starRating
        self.statusRaw = status.rawValue
        self.exifData = exifData
        self.imageAnalysis = imageAnalysis
        self.cullingProject = cullingProject
    }

    func updateCullingStatus(_ newStatus: CullingStatus) {
        self.status = newStatus
        // Note: GalleryElement removed - status is now managed directly on PhotoAsset
    }

}
