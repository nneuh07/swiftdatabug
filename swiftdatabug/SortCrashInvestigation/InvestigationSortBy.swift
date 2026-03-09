////
////  InvestigationSortBy.swift
////  swiftdatabug
////
////  Created by Nils Neuhaus on 09.03.26.
////
//
//
//import Foundation
//import SwiftData
//
//enum InvestigationSortBy: String, CaseIterable, Identifiable {
//    case date = "Date"
//    case quality = "Quality"
//
//    var id: Self { self }
//
//    var sortDescriptors: [SortDescriptor<InvestigationPhotoAsset>] {
//        switch self {
//        case .date:
//            return [SortDescriptor(\.creationDate, order: .reverse)]
//        case .quality:
//            return [
//                SortDescriptor(
//                    \.imageAnalysis?.overallAestheticsScore,
//                    order: .reverse
//                ),
//                SortDescriptor(\.creationDate, order: .reverse),
//            ]
//        }
//    }
//}
