//
//  Models.swift
//  SavePlate
//

import Foundation
import CoreLocation

enum DonorKitchenCategory: String, CaseIterable, Codable, Identifiable {
    case restaurant
    case homeKitchen

    var id: String { rawValue }

    var label: String {
        switch self {
        case .restaurant: "Restaurant"
        case .homeKitchen: "Home Kitchen"
        }
    }
}

/// Receiver ("I need food") account flavor for mock auth and routing.
enum ReceiverAuthKind: String, CaseIterable, Codable, Hashable, Identifiable {
    case ngo
    case individual

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ngo: "NGO"
        case .individual: "Individual"
        }
    }

    var profileLabel: String {
        switch self {
        case .ngo: "NGO name"
        case .individual: "Your name"
        }
    }
}

enum UserRole: String, CaseIterable, Codable, Identifiable {
    case donor
    case ngo
    case receiver

    var id: String { rawValue }

    var title: String {
        switch self {
        case .donor: "Food donor"
        case .ngo: "NGO / community org"
        case .receiver: "Individual receiver"
        }
    }

    var shortTitle: String {
        switch self {
        case .donor: "Donor"
        case .ngo: "NGO"
        case .receiver: "Receiver"
        }
    }
}

enum QuantityUnit: String, CaseIterable, Codable, Identifiable {
    case plates
    case kg

    var id: String { rawValue }

    var label: String {
        switch self {
        case .plates: "Plates"
        case .kg: "Kilograms"
        }
    }

    var abbreviation: String {
        switch self {
        case .plates: "plates"
        case .kg: "kg"
        }
    }
}

enum FoodType: String, CaseIterable, Codable, Identifiable {
    case vegetarian
    case nonVegetarian
    case packaged
    case mixed

    var id: String { rawValue }

    var label: String {
        switch self {
        case .vegetarian: "Vegetarian"
        case .nonVegetarian: "Non-veg"
        case .packaged: "Packaged"
        case .mixed: "Mixed"
        }
    }

    var symbolName: String {
        switch self {
        case .vegetarian: "leaf.fill"
        case .nonVegetarian: "fish.fill"
        case .packaged: "shippingbox.fill"
        case .mixed: "takeoutbag.and.cup.and.straw.fill"
        }
    }
}

struct Donation: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var foodName: String
    var quantity: Double
    var unit: QuantityUnit
    var foodType: FoodType
    var pickupLocation: String
    var latitude: Double?
    var longitude: Double?
    var expiry: Date
    var notes: String
    var createdAt: Date
    var isCancelled: Bool

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var isActive: Bool {
        !isCancelled && expiry > Date()
    }

    func estimatedMealsSaved() -> Int {
        switch unit {
        case .plates:
            max(1, Int(quantity.rounded(.down)))
        case .kg:
            max(1, Int((quantity / 0.35).rounded(.down)))
        }
    }
}

struct UrgentFoodRequest: Identifiable, Codable, Equatable {
    var id: UUID
    var organizationName: String
    var needSummary: String
    var mealsNeeded: Int
    var area: String
    var postedAt: Date
}

struct MilestoneBadge: Identifiable, Hashable {
    let id: String
    let title: String
    let mealsRequired: Int
    let symbolName: String
}

struct ReceiverClaimRecord: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var quantityText: String
    var pointsUsed: Int
    var claimedAt: Date
}

/// Food pantry / stock level for receiver home announcement.
enum ReceiverFoodStockLevel: String, CaseIterable, Codable, Identifiable, Hashable {
    case full
    case medium
    case low
    case empty

    var id: String { rawValue }

    var title: String {
        switch self {
        case .full: "Full"
        case .medium: "Medium"
        case .low: "Low"
        case .empty: "Empty"
        }
    }

    /// Maps to UI: green / yellow / orange / red
    var statusToken: String {
        switch self {
        case .full: "green"
        case .medium: "yellow"
        case .low: "orange"
        case .empty: "red"
        }
    }
}

struct ReceiverRider: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var phone: String
}

/// Mock distribution proof (photo/video placeholder for demo persistence).
struct ReceiverDistributionProof: Identifiable, Codable, Equatable {
    var id: UUID
    /// Linked donation for donor transparency; optional if general proof.
    var donationId: UUID?
    var caption: String
    /// `"photo"` or `"video"`
    var mediaKind: String
    /// Mock attachment label shown in UI.
    var attachmentStub: String
    var createdAt: Date
}

/// Community feedback tied to a distribution (optional donation link).
struct ReceiverCommunityReview: Identifiable, Codable, Equatable {
    var id: UUID
    var donationId: UUID?
    var authorName: String
    var reviewText: String
    var mediaNote: String
    var createdAt: Date
}

struct ReceiverNotificationItem: Identifiable, Codable, Equatable {
    var id: UUID
    var donorName: String
    var foodDetails: String
    var location: String
    var createdAt: Date
    var isRead: Bool
    /// `"donor"` or `"system"` (legacy display grouping).
    var category: String
    /// Smart routing: `newFood`, `requestApproved`, `dailyLimit`, `systemDaily`.
    var notifKind: String

    init(
        id: UUID = UUID(),
        donorName: String,
        foodDetails: String,
        location: String,
        createdAt: Date,
        isRead: Bool,
        category: String = "donor",
        notifKind: String = "newFood"
    ) {
        self.id = id
        self.donorName = donorName
        self.foodDetails = foodDetails
        self.location = location
        self.createdAt = createdAt
        self.isRead = isRead
        self.category = category
        self.notifKind = notifKind
    }

    enum CodingKeys: String, CodingKey {
        case id, donorName, foodDetails, location, createdAt, isRead, category, notifKind
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        donorName = try c.decode(String.self, forKey: .donorName)
        foodDetails = try c.decode(String.self, forKey: .foodDetails)
        location = try c.decode(String.self, forKey: .location)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        isRead = try c.decode(Bool.self, forKey: .isRead)
        category = try c.decodeIfPresent(String.self, forKey: .category) ?? "donor"
        if let k = try c.decodeIfPresent(String.self, forKey: .notifKind) {
            notifKind = k
        } else {
            if category == "system" {
                notifKind = "systemDaily"
            } else {
                notifKind = "newFood"
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(donorName, forKey: .donorName)
        try c.encode(foodDetails, forKey: .foodDetails)
        try c.encode(location, forKey: .location)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(isRead, forKey: .isRead)
        try c.encode(category, forKey: .category)
        try c.encode(notifKind, forKey: .notifKind)
    }
}

enum DonationTimeFilter: String, CaseIterable, Identifiable {
    case all
    case active
    case expired

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: "All"
        case .active: "Active"
        case .expired: "Past"
        }
    }
}

struct DonationFilters {
    var searchText: String = ""
    var foodType: FoodType?
    var timeFilter: DonationTimeFilter = .all
}
