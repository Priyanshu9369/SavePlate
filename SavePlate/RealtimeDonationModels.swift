//
//  RealtimeDonationModels.swift
//  SavePlate
//

import Foundation
import CoreLocation

enum AppUserRole: String, Codable, CaseIterable {
    case donor
    case ngo
    case individual
}

struct AppUser: Codable, Hashable {
    var id: String
    var name: String
    var role: AppUserRole
}

enum RealtimeDonationStatus: String, Codable, CaseIterable {
    case available
    case accepted
    case completed
}

struct RealtimeDonation: Identifiable, Codable, Hashable {
    var id: String
    var donorId: String
    var donorName: String
    var foodDetails: String
    var quantity: String
    var latitude: Double
    var longitude: Double
    var status: RealtimeDonationStatus
    var acceptedByUserId: String?
    var acceptedByName: String?
    var acceptedByRole: AppUserRole?
    var timestamp: Date
    var acceptedAt: Date?
    var completedAt: Date?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct RealtimeAppNotification: Identifiable, Codable, Hashable {
    var id: String
    var userId: String
    var title: String
    var body: String
    var donationId: String?
    var createdAt: Date
    var isRead: Bool
}

