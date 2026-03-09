//
//  ProcessStepError.swift
//  cullstudio
//
//  Created by Nils Neuhaus on 25.07.25.
//

import Foundation
import SwiftData

@Model
final class ProcessStepError: Identifiable {
    @Attribute(.unique) var id: UUID
    @Attribute var fileName: String
    @Attribute var errorDescription: String
    @Attribute var errorTypeRaw: String = ProcessStepErrorType.generic.rawValue
    @Attribute var createdDate: Date
    var processStep: ProcessStep?
    
    var errorType: ProcessStepErrorType {
        get { ProcessStepErrorType(rawValue: errorTypeRaw) ?? .generic }
        set { errorTypeRaw = newValue.rawValue }
    }
    
    init(
        id: UUID = UUID(),
        fileName: String,
        errorDescription: String,
        errorType: ProcessStepErrorType = .generic,
        createdDate: Date = Date(),
        processStep: ProcessStep? = nil
    ) {
        self.id = id
        self.fileName = fileName
        self.errorDescription = errorDescription
        self.errorTypeRaw = errorType.rawValue
        self.createdDate = createdDate
        self.processStep = processStep
    }
}

enum ProcessStepErrorType: String, Codable, Sendable {
    case generic
    case permissionDenied
    case fileNotFound
    case diskFull
    case unsupportedFormat
    case corruptedFile
    case alreadyExists
    case storageNotConnected
}
