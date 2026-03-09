//
//  ExifData.swift
//  cullstudio
//
//  Created by Nils Neuhaus on 05.07.25.
//

import SwiftData

@Model
final class ExifData: Codable {
    @Attribute var cameraModel: String?

    // Temporary investigation stubs to keep the wider app compiling while
    // reducing ExifData to the standalone repro shape.
    var aperture: Double? {
        get { nil }
        set { }
    }
    var shutterSpeed: Double? {
        get { nil }
        set { }
    }
    var iso: Int? {
        get { nil }
        set { }
    }
    var focalLength: Double? {
        get { nil }
        set { }
    }
    var cameraManufacturer: String? {
        get { nil }
        set { }
    }
    var lensModel: String? {
        get { nil }
        set { }
    }
    
    init(
        aperture: Double? = nil,
        shutterSpeed: Double? = nil,
        iso: Int? = nil,
        focalLength: Double? = nil,
        cameraManufacturer: String? = nil,
        cameraModel: String? = nil,
        lensModel: String? = nil
    ) {
        self.cameraModel = cameraModel
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case cameraModel
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cameraModel = try container.decodeIfPresent(String.self, forKey: .cameraModel)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(cameraModel, forKey: .cameraModel)
    }
}
