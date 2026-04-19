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
