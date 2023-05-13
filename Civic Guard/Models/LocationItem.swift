//
//  LocationItem.swift
//  Civic Guard
//
//  Created by Alexandru Rosca on 13.05.2023.
//

import Foundation
import MapKit

struct LocationItem: Identifiable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let description: String
    let imageUrl: String
    let status: Bool
    
    //Equatable
    static func == (lhs: LocationItem, rhs: LocationItem) -> Bool {
        lhs.id == rhs.id
    }
}
