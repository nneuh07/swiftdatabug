//
//  ProcessStep.swift
//  cullstudio
//
//  Created by Nils Neuhaus on 25.07.25.
//

import Foundation
import SwiftData

@Model
final class ProcessStep: Identifiable {
    @Attribute(.unique) var id: UUID
    @Attribute var typeRaw: Int
    @Attribute var statusRaw: Int
    @Attribute var processCount: Int
    @Attribute var createdDate: Date
    @Attribute var lastModified: Date
    @Relationship(deleteRule: .cascade, inverse: \ProcessStepError.processStep) var errors: [ProcessStepError]
    var projectProcess: ProjectProcess?
    
    init(
        id: UUID = UUID(),
        type: StepType,
        status: StepStatus = .idle,
        processCount: Int = 0,
        createdDate: Date = Date(),
        lastModified: Date = Date(),
        errors: [ProcessStepError] = [],
        projectProcess: ProjectProcess?
    ) {
        self.id = id
        self.typeRaw = type.rawValue
        self.statusRaw = status.rawValue
        self.processCount = processCount
        self.createdDate = createdDate
        self.lastModified = lastModified
        self.errors = errors
        self.projectProcess = projectProcess
    }
    
    var type: StepType {
        get { StepType(rawValue: typeRaw) ?? .assetCreating }
        set { 
            typeRaw = newValue.rawValue
            lastModified = Date()
        }
    }
    
    var status: StepStatus {
        get { StepStatus(rawValue: statusRaw) ?? .idle }
        set { 
            statusRaw = newValue.rawValue
            lastModified = Date()
        }
    }
    
    var processType: ProcessType? {
        return projectProcess?.processType
    }
    
    func updateStatus(_ newStatus: StepStatus) {
        status = newStatus
        lastModified = Date()
    }
    
    func updateProcessCount(_ count: Int) {
        processCount = count
        lastModified = Date()
    }
    
    func addError(_ error: ProcessStepError) {
        errors.append(error)
        lastModified = Date()
    }
}

enum StepType: Int, Codable, CaseIterable {
    case fileScanning = 0
    case assetCreating = 1
    case thumbnailCreating = 2
    case previewCreating = 3
    case groupingCreating = 4
    case movingRejectedFiles = 5
    case exportingXMPFiles = 6
    case imageAnalyzing = 7
    
    var displayName: String {
        switch self {
        case .fileScanning: return "File Scanning"
        case .assetCreating: return "Asset Creating"
        case .thumbnailCreating: return "Thumbnail Creating"
        case .previewCreating: return "Preview Creating"
        case .groupingCreating: return "Grouping Creating"
        case .movingRejectedFiles: return "Moving Rejected Files"
        case .exportingXMPFiles: return "Exporting XMP Files"
        case .imageAnalyzing: return "Image Analysis"
        }
    }
    
    static var importSteps: [StepType] {
        return [.fileScanning, .assetCreating, .thumbnailCreating, .previewCreating, .imageAnalyzing, .groupingCreating]
    }
    
    static var exportSteps: [StepType] {
        return [.movingRejectedFiles, .exportingXMPFiles]
    }
}

enum StepStatus: Int, Codable, CaseIterable {
    case idle = 0
    case ongoing = 1
    case finished = 2
    case failed = 3
    
    var displayName: String {
        switch self {
        case .idle: return "Idle"
        case .ongoing: return "Ongoing"
        case .finished: return "Finished"
        case .failed: return "Failed"
        }
    }
}
