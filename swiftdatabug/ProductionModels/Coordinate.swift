//
//  Coordinate.swift
//  cullstudio
//
//  Created by Nils Neuhaus on 08.06.25.
//


import CoreLocation

struct Coordinate: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    var clLocationCoordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var isValid: Bool {
        CLLocationCoordinate2DIsValid(clLocationCoordinate2D)
    }
}

extension Coordinate {    
    func distance(to other: Coordinate) -> CLLocationDistance {
        let location1 = CLLocation(latitude: latitude, longitude: longitude)
        let location2 = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return location1.distance(from: location2)
    }
}
