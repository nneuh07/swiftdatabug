//
//  FileMetaData.swift
//  cullstudio
//
//  Created by Nils Neuhaus on 13.06.25.
//


import Foundation
import SwiftData

@Model
final class FileMetaData: Identifiable, Hashable {
    @Relationship(deleteRule: .cascade) var fileBookmark: Bookmark
    @Relationship(deleteRule: .cascade) var directoryBookmark: Bookmark
    @Attribute var fileName: String
    @Attribute var fileExtension: String
    @Attribute var baseName: String
    @Attribute var fileSize: Int64

    // Temporary investigation stubs to keep the wider app compiling while
    // reducing FileMetaData to the standalone repro shape.
    var sidecarBookmark: Bookmark? {
        get { nil }
        set { }
    }
    var sidecarFileName: String? {
        get { nil }
        set { }
    }
    var sidecarFileExtension: String? {
        get { nil }
        set { }
    }

    init(
        fileBookmark: Bookmark,
        fileName: String,
        fileExtension: String,
        baseName: String,
        fileSize: Int64,
        directoryBookmark: Bookmark,
        sidecarBookmark: Bookmark? = nil,
        sidecarFileName: String? = nil,
        sidecarFileExtension: String? = nil
    ) {
        self.fileBookmark = fileBookmark
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.baseName = baseName
        self.fileSize = fileSize
        self.directoryBookmark = directoryBookmark
    }

    var isInRejectedFolder: Bool {
        fileBookmark.url.path.contains("/_Rejected/")
    }
    
    static func == (lhs: FileMetaData, rhs: FileMetaData) -> Bool {
        lhs.fileBookmark == rhs.fileBookmark &&
        lhs.fileName == rhs.fileName &&
        lhs.fileExtension == rhs.fileExtension &&
        lhs.baseName == rhs.baseName &&
        lhs.fileSize == rhs.fileSize &&
        lhs.directoryBookmark == rhs.directoryBookmark &&
        lhs.sidecarBookmark == rhs.sidecarBookmark &&
        lhs.sidecarFileName == rhs.sidecarFileName &&
        lhs.sidecarFileExtension == rhs.sidecarFileExtension
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fileBookmark)
        hasher.combine(fileName)
        hasher.combine(fileExtension)
        hasher.combine(baseName)
        hasher.combine(fileSize)
        hasher.combine(directoryBookmark)
        hasher.combine(sidecarBookmark)
        hasher.combine(sidecarFileName)
        hasher.combine(sidecarFileExtension)
    }
}
