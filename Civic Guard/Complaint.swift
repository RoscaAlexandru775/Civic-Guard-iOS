//
//  Complaint.swift
//  Civic Guard
//
//  Created by Alexandru Rosca on 11.05.2023.
//

import Foundation

struct Complaint: Decodable {
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


//struct ComplaintsResponse {
//    let complaints: [Complaint]
//}
//
//struct Complaint{
//    let userId: String
//    let status: String
//    let title: String
//    let description: String
//    let institutionName: String
//    let locationLatitude: String
//    let locationLongitude: String
//    let locationAddress: String
//    let imageUrl: String
//
//    enum CodingKeys: String {
//        case userId = "userId"
//        case status = "status"
//        case title = "title"
//        case description = "description"
//        case institutionName = "institutionName"
//        case locationLatitude = "locationLatitude"
//        case locationLongitude = "locationLongitude"
//        case locationAddress = "locationAddress"
//        case imageUrl = "imageUrl"
//
//    }
//}
