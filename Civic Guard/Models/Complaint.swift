//
//  Complaint.swift
//  Civic Guard
//
//  Created by Alexandru Rosca on 13.05.2023.
//

import Foundation

struct Complaint: Decodable {
    var id: String
    var userId: String
    var status: Bool
    var locationLatitude: String
    var title: String
    var locationLongitude: String
    var creationDate: String
    var description: String
    var imageUrl: String
    var locationAddress: String
    var institutionName: String
}
