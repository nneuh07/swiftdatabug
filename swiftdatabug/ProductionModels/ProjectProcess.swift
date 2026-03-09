//
//  ProjectProcess.swift
//  cullstudio
//
//  Created by Nils Neuhaus on 25.07.25.
//

import Foundation
import SwiftData

enum ProcessType: Int, Codable, CaseIterable {
    case `import` = 0
    case export = 1
    
    var displayName: String {
        switch self {
        case .import:
            return "Import"
        case .export:
            return "Export"
        }
    }
}

@Model
final class ProjectProcess: Identifiable {
    @Attribute(.unique) var id: UUID
    @Attribute var statusRaw: Int
    @Attribute var processTypeRaw: Int
    @Attribute var createdDate: Date
    @Attribute var lastModified: Date
    @Relationship(deleteRule: .cascade, inverse: \ProcessStep.projectProcess) var steps: [ProcessStep]
    weak var cullingProject: CullingProject?
    
    init(
        id: UUID = UUID(),
        status: ProcessStatus = .idle,
        processType: ProcessType = .import,
        createdDate: Date = Date(),
        lastModified: Date = Date(),
        cullingProject: CullingProject?
    ) {
        self.id = id
        self.statusRaw = status.rawValue
        self.processTypeRaw = processType.rawValue
        self.createdDate = createdDate
        self.lastModified = lastModified
        self.cullingProject = cullingProject
        self.steps = []
    }
    
    var status: ProcessStatus {
        get { ProcessStatus(rawValue: statusRaw) ?? .idle }
        set {
            statusRaw = newValue.rawValue
            lastModified = Date()
        }
    }
    
    var processType: ProcessType {
        get { ProcessType(rawValue: processTypeRaw) ?? .import }
        set {
            processTypeRaw = newValue.rawValue
            lastModified = Date()
        }
    }
    
    func updateStatus(_ newStatus: ProcessStatus) {
        status = newStatus
        lastModified = Date()
    }
}

enum ProcessStatus: Int, Codable, CaseIterable {
    case idle = 0
    case ongoing = 1
    case finished = 2
    case failed = 3
}
