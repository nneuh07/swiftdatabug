//
//  CullingStatus.swift
//  cullstudio
//
//  Created by Nils Neuhaus on 02.06.25.
//

import SwiftUI

enum CullingStatus: Int, Codable, CaseIterable, Equatable {
    case pending = 0
    case accepted = 1
    case rejected = 2
}

extension CullingStatus {
    var color: Color {
        switch self {
        case .pending:
            return .orange
        case .rejected:
            return .red
        case .accepted:
            return .green
        }
    }
}
