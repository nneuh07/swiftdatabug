import Foundation
import SwiftData

enum GroupingCase: String, Codable, Hashable {
    case noGrouping, time, location, similarity
}

enum GroupingSimilarityLevel: String, Codable, Hashable {
    case veryHigh
    case high
    case medium

    var sortIndex: Int {
        switch self {
        case .veryHigh: return 0
        case .high: return 1
        case .medium: return 2
        }
    }

        var thresholdValue: Double {
            switch self {
            case .veryHigh: return 0.15
            case .high: return 0.26
            case .medium: return 0.35
            }
        }
}

enum GroupingType: Hashable, Identifiable, Sendable {
    var id: String {
        switch self {
        case .noGrouping: return "noGrouping"
        case .time(let window): return "time:\(window)"
        case .location(let radius): return "location:\(radius)"
        case .similarity(let level): return "similarity:\(level.rawValue)"
        }
    }

    var groupingCase: GroupingCase {
        switch self {
        case .noGrouping: return .noGrouping
        case .time: return .time
        case .location: return .location
        case .similarity: return .similarity
        }
    }

    var valueRaw: String {
        switch self {
        case .noGrouping: return "noGrouping"
        case .time(let window): return "\(window)"
        case .location(let radius): return "\(radius)"
        case .similarity(let level): return level.rawValue
        }
    }

    case noGrouping
    case time(window: TimeInterval)
    case location(radius: Double)
    case similarity(level: GroupingSimilarityLevel)
}

@Model
final class GroupingCriteria: Identifiable {
    @Attribute var id: String
    @Attribute var value: String
    @Attribute var groupingCaseRaw: String

    var type: GroupingType {
        GroupingType(groupingCase: groupingCase, rawValue: value) ?? .noGrouping
    }
    
    var groupingCase: GroupingCase {
        get { GroupingCase(rawValue: groupingCaseRaw)! }
        set { groupingCaseRaw = newValue.rawValue }
    }

    init(type: GroupingType) {
        self.id = type.id
        self.value = type.valueRaw
        self.groupingCaseRaw = type.groupingCase.rawValue
    }
}

extension GroupingType {
    init?(groupingCase: GroupingCase, rawValue: String) {
        switch groupingCase {
        case .noGrouping:
            self = .noGrouping
        case .similarity:
            guard let level = GroupingSimilarityLevel(rawValue: rawValue) else {
                return nil
            }
            self = .similarity(level: level)
        case .time:
            let window = TimeInterval(rawValue) ?? 0
            self = .time(window: window)
        case .location:
            let radius = Double(rawValue) ?? 0
            self = .location(radius: radius)
        }
    }

    init?(idString: String) {
        if idString == GroupingType.noGrouping.id {
            self = .noGrouping
            return
        }

        let components = idString.split(separator: ":", maxSplits: 1).map(String.init)
        guard let caseValue = components.first else {
            return nil
        }

        let groupingCase = GroupingCase(rawValue: caseValue)
        let value = components.count == 2 ? components[1] : ""

        guard let groupingCase, let resolved = GroupingType(groupingCase: groupingCase, rawValue: value) else {
            return nil
        }

        self = resolved
    }
}
