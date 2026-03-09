//
//  FileBookmark.swift
//  cullstudio
//
//  Created by Nils Neuhaus on 12.06.25.
//

import Foundation
import SwiftData

protocol AnyBookmark {
    var url: URL { get }
    var bookmark: Data { get }
}

@Model
final class Bookmark: AnyBookmark {
    @Attribute var url: URL
    @Attribute var bookmark: Data
    
    init(url: URL, bookmark: Data = Data()) {
        self.url = url
        self.bookmark = bookmark
    }
}

extension AnyBookmark {
    func withSecurityScope<T>(
        _ perform: (URL) throws -> T
    ) throws -> T {
        var isStale = false
        let URL = try URL(
            resolvingBookmarkData: bookmark,
            options: [],
            bookmarkDataIsStale: &isStale
        )

        let accessGranted = URL.startAccessingSecurityScopedResource()
        guard accessGranted else {
            throw BookmarkError.accessDenied(URL.path())
        }

        defer {
            if accessGranted {
                URL.stopAccessingSecurityScopedResource()
            }
        }

        return try perform(URL)
    }
    
    func withSecurityScope<T>(
        _ perform: (URL) async throws -> T
    ) async throws -> T {
        var isStale = false
        let URL = try URL(
            resolvingBookmarkData: bookmark,
            options: [],
            bookmarkDataIsStale: &isStale
        )

        let accessGranted = URL.startAccessingSecurityScopedResource()
        guard accessGranted else {
            throw BookmarkError.accessDenied(URL.path())
        }

        defer {
            if accessGranted {
                URL.stopAccessingSecurityScopedResource()
            }
        }

        return try await perform(URL)
    }
}

enum BookmarkError: Error {
    case accessDenied(String)
}
