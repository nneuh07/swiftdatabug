import Foundation
import SwiftData

enum GroupType: String, Codable, CaseIterable {
    case normal
    case filler
    case appendedFillerCollection
}

@Model
final class PhotoGroup: Identifiable {
    @Attribute(.unique) var id: UUID
    @Attribute var createdDate: Date
    @Attribute var modifiedDate: Date = Date()
    @Attribute var name: String?
    @Attribute var groupDateRepresentation: Date
    @Attribute var groupTypeRaw: String
    // Temporary investigation reduction: keep PhotoGroup compilable without
    // requiring PhotoAsset.photoGroups to remain a persisted field.
    @Relationship(deleteRule: .nullify) var photoAssets: [PhotoAsset]
    var cullingProject: CullingProject?
    var groupingCriteria: GroupingCriteria?
    
    var groupType: GroupType {
        get {
            GroupType(rawValue: groupTypeRaw) ?? .normal
        }
        set {
            groupTypeRaw = newValue.rawValue
        }
    }
    
    init(
        id: UUID = UUID(),
        groupingCriteria: GroupingCriteria? = nil,
        createdDate: Date = Date(),
        name: String? = nil,
        groupDateRepresentation: Date = Date(),
        photoAssets: [PhotoAsset] = [],
        cullingProject: CullingProject,
        groupType: GroupType = .normal
    ) {
        self.id = id
        self.groupingCriteria = groupingCriteria
        self.createdDate = createdDate
        self.name = name
        self.groupDateRepresentation = groupDateRepresentation
        self.groupTypeRaw = groupType.rawValue
        self.photoAssets = photoAssets
        self.cullingProject = cullingProject
    }
    
    var photoCount: Int {
        photoAssets.count
    }
    
    var groupStatus: [CullingStatus] {
        return Array(Set(photoAssets.map { $0.status }))
    }
    
    var timeRange: ClosedRange<Date>? {
        let dates = photoAssets.map { $0.creationDate }
        guard let min = dates.min(), let max = dates.max() else { return nil }
        return min...max
    }
    
    var displayName: String {
        if let name = name {
            return name
        }
        
        guard let criteria = groupingCriteria else {
            return "Ungrouped Photos"
        }
        
        switch criteria.type {
        case .noGrouping:
            return "Individual Photos"
        case .time:
            if let timeRange = timeRange {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                return "\(formatter.string(from: timeRange.lowerBound)) - \(formatter.string(from: timeRange.upperBound))"
            }
            return "Time Group"
        case .location:
            return "Location Group"
        case .similarity:
            return "Similar Photos"
        }
    }
}
