//
//  DonationStore.swift
//  SavePlate
//

import Foundation

@MainActor
@Observable
final class DonationStore {
    private let donationsKey = "saveplate.donations.v1"
    private let pledgedKey = "saveplate.urgent.pledged.v1"
    private let roleKey = "saveplate.userRole"
    private let areaKey = "saveplate.homeArea"
    private let kitchenNameKey = "hearth.kitchenName"
    private let donorCategoryKey = "hearth.donorCategory"
    private let accountEmailKey = "hearth.accountEmail"
    private let receiverProfileNameKey = "hearth.receiverProfileName"
    private let receiverCityKey = "hearth.receiverCity"

    var donations: [Donation] = []
    var pledgedUrgentRequestIDs: Set<UUID> = []
    var userRole: UserRole = .donor {
        didSet { UserDefaults.standard.set(userRole.rawValue, forKey: roleKey) }
    }

    var homeArea: String = "" {
        didSet { UserDefaults.standard.set(homeArea, forKey: areaKey) }
    }

    /// Display name on home (e.g. "Hearth Kitchen").
    var kitchenDisplayName: String = "Hearth Kitchen" {
        didSet { UserDefaults.standard.set(kitchenDisplayName, forKey: kitchenNameKey) }
    }

    var donorKitchenCategory: DonorKitchenCategory = .restaurant {
        didSet { UserDefaults.standard.set(donorKitchenCategory.rawValue, forKey: donorCategoryKey) }
    }

    var accountEmail: String = "" {
        didSet { UserDefaults.standard.set(accountEmail, forKey: accountEmailKey) }
    }

    /// Shown on NGO / receiver home (e.g. “Harvest Hope NGO”).
    var receiverProfileName: String = "Harvest Hope NGO" {
        didSet { UserDefaults.standard.set(receiverProfileName, forKey: receiverProfileNameKey) }
    }

    var receiverCity: String = "Seattle, WA" {
        didSet { UserDefaults.standard.set(receiverCity, forKey: receiverCityKey) }
    }

    let mealGoal: Int = 500

    static let milestoneBadges: [MilestoneBadge] = [
        MilestoneBadge(id: "first", title: "First plate", mealsRequired: 1, symbolName: "hand.raised.fill"),
        MilestoneBadge(id: "starter", title: "Community starter", mealsRequired: 25, symbolName: "sparkles"),
        MilestoneBadge(id: "builder", title: "Impact builder", mealsRequired: 100, symbolName: "flame.fill"),
        MilestoneBadge(id: "champion", title: "Waste warrior", mealsRequired: 250, symbolName: "shield.lefthalf.filled"),
        MilestoneBadge(id: "legend", title: "Neighborhood legend", mealsRequired: 500, symbolName: "star.circle.fill"),
    ]

    let sampleUrgentRequests: [UrgentFoodRequest] = [
        UrgentFoodRequest(
            id: UUID(uuidString: "A1000001-0001-4001-8001-000000000001")!,
            organizationName: "Hope Kitchen Collective",
            needSummary: "Hot meals for 40 people tonight — any surplus dinner trays welcome.",
            mealsNeeded: 40,
            area: "Indiranagar",
            postedAt: Date().addingTimeInterval(-3600)
        ),
        UrgentFoodRequest(
            id: UUID(uuidString: "A1000001-0001-4001-8001-000000000002")!,
            organizationName: "StreetReach NGO",
            needSummary: "Packaged bread, fruit, or safe packaged snacks for morning distribution.",
            mealsNeeded: 60,
            area: "Koramangala",
            postedAt: Date().addingTimeInterval(-7200)
        ),
        UrgentFoodRequest(
            id: UUID(uuidString: "A1000001-0001-4001-8001-000000000003")!,
            organizationName: "School Lunch Bridge",
            needSummary: "Vegetarian lunch boxes for students — pickup before 11 a.m. preferred.",
            mealsNeeded: 35,
            area: "Jayanagar",
            postedAt: Date().addingTimeInterval(-5400)
        ),
    ]

    init() {
        if let raw = UserDefaults.standard.string(forKey: roleKey), let r = UserRole(rawValue: raw) {
            userRole = r
        }
        homeArea = UserDefaults.standard.string(forKey: areaKey) ?? ""
        if let kn = UserDefaults.standard.string(forKey: kitchenNameKey), !kn.isEmpty {
            kitchenDisplayName = kn
        }
        if let dc = UserDefaults.standard.string(forKey: donorCategoryKey),
           let cat = DonorKitchenCategory(rawValue: dc) {
            donorKitchenCategory = cat
        }
        accountEmail = UserDefaults.standard.string(forKey: accountEmailKey) ?? ""
        if let rn = UserDefaults.standard.string(forKey: receiverProfileNameKey), !rn.isEmpty {
            receiverProfileName = rn
        }
        if let c = UserDefaults.standard.string(forKey: receiverCityKey), !c.isEmpty {
            receiverCity = c
        }
        let hadStoredDonations = UserDefaults.standard.object(forKey: donationsKey) != nil
        load()
        loadPledged()
        if !hadStoredDonations {
            seedPreviewDataIfNeeded()
            persist()
        }
    }

    private func seedPreviewDataIfNeeded() {
        let cal = Calendar.current
        let now = Date()
        donations = [
            Donation(
                id: UUID(),
                foodName: "Vegetable biryani trays",
                quantity: 24,
                unit: .plates,
                foodType: .vegetarian,
                pickupLocation: "12th Main, Indiranagar",
                latitude: 12.9719,
                longitude: 77.6412,
                expiry: now.addingTimeInterval(4 * 3600),
                notes: "Restaurant surplus; please bring containers.",
                createdAt: cal.date(byAdding: .day, value: -1, to: now) ?? now,
                isCancelled: false
            ),
            Donation(
                id: UUID(),
                foodName: "Packaged sandwiches",
                quantity: 18,
                unit: .plates,
                foodType: .packaged,
                pickupLocation: "Forum Mall back gate",
                latitude: 12.9349,
                longitude: 77.6113,
                expiry: now.addingTimeInterval(3600),
                notes: "Event leftovers, chilled.",
                createdAt: cal.date(byAdding: .hour, value: -6, to: now) ?? now,
                isCancelled: false
            ),
            Donation(
                id: UUID(),
                foodName: "Cooked curry + rice",
                quantity: 8,
                unit: .kg,
                foodType: .nonVegetarian,
                pickupLocation: "HSR Layout Sector 2",
                latitude: 12.9116,
                longitude: 77.6479,
                expiry: now.addingTimeInterval(-3600),
                notes: "Non-veg; consumed quickly.",
                createdAt: cal.date(byAdding: .day, value: -3, to: now) ?? now,
                isCancelled: false
            ),
        ]
    }

    // MARK: - Persistence

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: donationsKey),
              let decoded = try? JSONDecoder().decode([Donation].self, from: data) else {
            donations = []
            return
        }
        donations = decoded
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(donations) {
            UserDefaults.standard.set(data, forKey: donationsKey)
        }
    }

    private func loadPledged() {
        guard let data = UserDefaults.standard.data(forKey: pledgedKey),
              let ids = try? JSONDecoder().decode([UUID].self, from: data) else { return }
        pledgedUrgentRequestIDs = Set(ids)
    }

    private func persistPledged() {
        let ids = Array(pledgedUrgentRequestIDs)
        if let data = try? JSONEncoder().encode(ids) {
            UserDefaults.standard.set(data, forKey: pledgedKey)
        }
    }

    // MARK: - CRUD

    func add(_ donation: Donation) {
        donations.insert(donation, at: 0)
        persist()
    }

    func update(_ donation: Donation) {
        guard let i = donations.firstIndex(where: { $0.id == donation.id }) else { return }
        donations[i] = donation
        persist()
    }

    func delete(_ donation: Donation) {
        donations.removeAll { $0.id == donation.id }
        persist()
    }

    func cancel(_ donation: Donation) {
        guard var d = donations.first(where: { $0.id == donation.id }) else { return }
        d.isCancelled = true
        update(d)
    }

    func togglePledge(for request: UrgentFoodRequest) {
        if pledgedUrgentRequestIDs.contains(request.id) {
            pledgedUrgentRequestIDs.remove(request.id)
        } else {
            pledgedUrgentRequestIDs.insert(request.id)
        }
        persistPledged()
    }

    // MARK: - Filtering

    func filteredDonations(_ filters: DonationFilters) -> [Donation] {
        donations.filter { d in
            if !filters.searchText.isEmpty {
                let q = filters.searchText.lowercased()
                let match = d.foodName.lowercased().contains(q)
                    || d.pickupLocation.lowercased().contains(q)
                    || d.notes.lowercased().contains(q)
                if !match { return false }
            }
            if let t = filters.foodType, d.foodType != t { return false }
            switch filters.timeFilter {
            case .all: break
            case .active:
                if !d.isActive { return false }
            case .expired:
                if d.isActive { return false }
            }
            return true
        }
        .sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Metrics

    var totalMealsDonated: Int {
        donations.filter { !$0.isCancelled }.reduce(0) { $0 + $1.estimatedMealsSaved() }
    }

    /// Estimated kg contributed (plates × ~0.35 kg).
    var totalKgDonated: Double {
        donations.filter { !$0.isCancelled }.reduce(0.0) { acc, d in
            switch d.unit {
            case .kg: acc + d.quantity
            case .plates: acc + d.quantity * 0.35
            }
        }
    }

    var mealsSavedThisCalendarMonth: Int {
        let cal = Calendar.current
        let now = Date()
        guard let start = cal.date(from: cal.dateComponents([.year, .month], from: now)) else { return 0 }
        return donations.filter { !$0.isCancelled && $0.createdAt >= start }.reduce(0) { $0 + $1.estimatedMealsSaved() }
    }

    var donationsCountThisCalendarMonth: Int {
        let cal = Calendar.current
        let now = Date()
        guard let start = cal.date(from: cal.dateComponents([.year, .month], from: now)) else { return 0 }
        return donations.filter { $0.createdAt >= start }.count
    }

    /// Rough CO₂ estimate for storytelling (not scientific).
    var estimatedCO2KgReduced: Int {
        max(0, Int(totalKgDonated * 2.0))
    }

    var impactTierTitle: String {
        let kg = totalKgDonated
        switch kg {
        case ..<25: return "Supporter"
        case ..<80: return "Ally"
        case ..<150: return "Guardian"
        default: return "Champion"
        }
    }

    var donorRankDisplay: Int {
        min(12, max(4, 14 - (totalMealsDonated / 200)))
    }

    var activeDonationCount: Int {
        donations.filter(\.isActive).count
    }

    var nearbyAvailableCount: Int {
        let area = homeArea.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let active = donations.filter(\.isActive)
        guard !area.isEmpty else { return active.count }
        return active.filter { $0.pickupLocation.lowercased().contains(area) }.count
    }

    func categoryCounts() -> [(FoodType, Int)] {
        let relevant = donations.filter { !$0.isCancelled }
        return FoodType.allCases.map { type in
            let meals = relevant.filter { $0.foodType == type }.reduce(0) { $0 + $1.estimatedMealsSaved() }
            return (type, meals)
        }
    }

    func weeklyMealTrend(lastDays: Int = 7) -> [(Date, Int)] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        guard let from = cal.date(byAdding: .day, value: -(lastDays - 1), to: start) else { return [] }
        var buckets: [Date: Int] = [:]
        for offset in 0..<lastDays {
            if let day = cal.date(byAdding: .day, value: offset, to: from) {
                buckets[cal.startOfDay(for: day)] = 0
            }
        }
        for d in donations where !d.isCancelled {
            let day = cal.startOfDay(for: d.createdAt)
            if day >= from, day <= start, buckets[day] != nil {
                buckets[day, default: 0] += d.estimatedMealsSaved()
            }
        }
        return buckets.keys.sorted().map { ($0, buckets[$0] ?? 0) }
    }

    func monthlyMealTrend(monthsBack: Int = 6) -> [(String, Int)] {
        let cal = Calendar.current
        let now = Date()
        var result: [(String, Int)] = []
        for m in 0..<monthsBack {
            guard let monthStart = cal.date(byAdding: .month, value: -m, to: now) else { continue }
            let comps = cal.dateComponents([.year, .month], from: monthStart)
            guard let start = cal.date(from: comps),
                  let nextMonth = cal.date(byAdding: .month, value: 1, to: start),
                  let end = cal.date(byAdding: .second, value: -1, to: nextMonth) else { continue }
            let meals = donations.filter { !$0.isCancelled && $0.createdAt >= start && $0.createdAt <= end }
                .reduce(0) { $0 + $1.estimatedMealsSaved() }
            let label = DateFormatter.monthShort.string(from: start)
            result.append((label, meals))
        }
        return result.reversed()
    }

    func mealsThisWeekVsLastWeek() -> (thisWeek: Int, lastWeek: Int) {
        let cal = Calendar.current
        let now = Date()
        guard let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let lastWeekStart = cal.date(byAdding: .weekOfYear, value: -1, to: weekStart),
              let lastWeekEnd = cal.date(byAdding: .second, value: -1, to: weekStart) else {
            return (0, 0)
        }
        let this = donations.filter { !$0.isCancelled && $0.createdAt >= weekStart }.reduce(0) { $0 + $1.estimatedMealsSaved() }
        let last = donations.filter { !$0.isCancelled && $0.createdAt >= lastWeekStart && $0.createdAt <= lastWeekEnd }
            .reduce(0) { $0 + $1.estimatedMealsSaved() }
        return (this, last)
    }

    func topFoodCategory() -> (FoodType, Int)? {
        let pairs = categoryCounts().filter { $0.1 > 0 }
        return pairs.max(by: { $0.1 < $1.1 })
    }

    func locationHeatmap() -> [(location: String, meals: Int)] {
        var map: [String: Int] = [:]
        for d in donations where !d.isCancelled {
            let key = normalizedLocationKey(d.pickupLocation)
            map[key, default: 0] += d.estimatedMealsSaved()
        }
        return map.map { (location: $0.key, meals: $0.value) }
            .sorted { $0.meals > $1.meals }
    }

    private func normalizedLocationKey(_ raw: String) -> String {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return "Unspecified" }
        return t.split(separator: ",").first.map(String.init)?.trimmingCharacters(in: .whitespaces) ?? t
    }

    // MARK: - Streak

    var currentDonationStreakDays: Int {
        let cal = Calendar.current
        let donationDays: Set<Date> = Set(
            donations
                .filter { !$0.isCancelled }
                .map { cal.startOfDay(for: $0.createdAt) }
        )
        guard !donationDays.isEmpty else { return 0 }
        var streak = 0
        var cursor = cal.startOfDay(for: Date())
        while donationDays.contains(cursor) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        if streak == 0 {
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: Date())) else { return 0 }
            cursor = yesterday
            while donationDays.contains(cursor) {
                streak += 1
                guard let prev = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
                cursor = prev
            }
        }
        return streak
    }

    var donatedToday: Bool {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return donations.contains { !$0.isCancelled && cal.startOfDay(for: $0.createdAt) == today }
    }
}

private extension DateFormatter {
    static let monthShort: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM"
        return f
    }()
}
