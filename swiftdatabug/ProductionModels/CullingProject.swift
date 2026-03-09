//
//  CullingProject.swift
//  cullstudio
//
//  Created by Nils Neuhaus on 08.06.25.
//

import Foundation
import SwiftData

@Model
final class CullingProject: Identifiable {
    @Attribute(.unique) var id: UUID
    @Attribute var name: String
    @Relationship(deleteRule: .cascade) var folders: [Bookmark]
    @Attribute var createdDate: Date
    @Attribute var lastModified: Date
    @Attribute var projectStatusRaw: Int
    @Attribute var exportDate: Date?
    @Relationship(deleteRule: .cascade, inverse: \PhotoAsset.cullingProject) var photoAssets: [PhotoAsset]

    // Temporary investigation stubs to keep the wider app compiling while
    // removing extra persisted relationships from the Stage 1 schema.
    var photoGroups: [PhotoGroup] {
        get { [] }
        set { }
    }
    var processes: [ProjectProcess] {
        get { [] }
        set { }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        folders: [Bookmark],
        createdDate: Date,
        lastModified: Date,
        projectStatus: ProjectStatus = .created,
        exportDate: Date? = nil,
        photoAssets: [PhotoAsset] = [],
        photoGroups: [PhotoGroup] = []
    ) {
        self.id = id
        self.name = name
        self.folders = folders
        self.createdDate = createdDate
        self.lastModified = lastModified
        self.projectStatusRaw = projectStatus.rawValue
        self.exportDate = exportDate
        self.photoAssets = photoAssets
    }

    var projectStatus: ProjectStatus {
        get { ProjectStatus(rawValue: projectStatusRaw) ?? .created }
        set { projectStatusRaw = newValue.rawValue }
    }
    
    // Convenience property for backward compatibility
    var importProcess: ProjectProcess? {
        processes.first { $0.processType == .import }
    }
    
    var readyForBrowsing: Bool {
        projectStatus == .browsable || projectStatus == .cullingReady
    }
    
    var readyForCulling: Bool {
        projectStatus == .cullingReady
    }

    var totalPhotos: Int { photoAssets.count }
    var acceptedCount: Int { photoAssets.filter { $0.status == .accepted }.count }
    var rejectedCount: Int { photoAssets.filter { $0.status == .rejected }.count }
    var pendingCount: Int { photoAssets.filter { $0.status == .pending }.count }
    var isComplete: Bool { totalPhotos > 0 && pendingCount == 0 }
    var wasExported: Bool { exportDate != nil }

    // Computed property for display purposes
    var folderPathsDescription: String {
        if folders.count == 1 {
            return folders.first?.url.lastPathComponent ?? "Unknown"
        } else {
            return "\(folders.count) folders"
        }
    }
    
    var folderNames: [String] { folders.map { $0.url.lastPathComponent } }

    func updateProjectStatus(_ status: ProjectStatus) {
        projectStatus = status
        lastModified = Date()
    }
    func setPhotoAssets(_ assets: [PhotoAsset]) {
        photoAssets = assets
        lastModified = Date()
    }
    func updateName(_ newName: String) {
        guard !newName.isEmpty else { return }
        self.name = newName
        lastModified = Date()
    }
    
    func markAsExported() {
        exportDate = Date()
        lastModified = Date()
    }
}

enum ProjectStatus: Int, Codable {
    case created = 0
    case browsable = 1
    case cullingReady = 2
}
