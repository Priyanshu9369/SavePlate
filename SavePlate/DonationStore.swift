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
    private let receiverAvatarSymbolKey = "hearth.receiver.avatarSymbol"
    private let receiverBioKey = "hearth.receiver.bio"
    private let receiverClaimsKey = "hearth.receiver.claimHistory"
    private let receiverNotificationsKey = "hearth.receiver.notifications"
    private let receiverDailyLimitIndividualKey = "hearth.receiver.dailyLimit.individual"
    private let receiverDailyLimitNGOKey = "hearth.receiver.dailyLimit.ngo"
    private let receiverMealsTodayKey = "hearth.receiver.mealsToday"
    private let receiverLastResetDayKey = "hearth.receiver.lastResetDay"
    private let receiverTotalPointsKey = "hearth.receiver.totalPoints"
    private let receiverPointsPerMealKey = "hearth.receiver.pointsPerMeal"
    private let receiverLifetimeMealsKey = "hearth.receiver.lifetimeMeals"
    private let receiverRidersKey = "hearth.receiver.riders"
    private let receiverStockLevelKey = "hearth.receiver.stockLevel"
    private let receiverProofsKey = "hearth.receiver.proofs"
    private let receiverReviewsKey = "hearth.receiver.reviews"
    private let lastDailyLimitNotifDayKey = "hearth.receiver.lastDailyLimitNotifDay"

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

    /// SF Symbol avatar used for receiver profile mock picture.
    var receiverAvatarSymbol: String = "person.fill" {
        didSet { UserDefaults.standard.set(receiverAvatarSymbol, forKey: receiverAvatarSymbolKey) }
    }

    /// Short legitimacy description on receiver profile.
    var receiverBio: String = "Verified receiver helping distribute food responsibly to people in need." {
        didSet { UserDefaults.standard.set(receiverBio, forKey: receiverBioKey) }
    }

    /// Mock claim history list shown in receiver profile.
    var receiverClaimHistory: [ReceiverClaimRecord] = [] {
        didSet {
            if let data = try? JSONEncoder().encode(receiverClaimHistory) {
                UserDefaults.standard.set(data, forKey: receiverClaimsKey)
            }
        }
    }

    /// Latest donor posts shown in receiver notification center.
    var receiverNotifications: [ReceiverNotificationItem] = [] {
        didSet {
            if let data = try? JSONEncoder().encode(receiverNotifications) {
                UserDefaults.standard.set(data, forKey: receiverNotificationsKey)
            }
        }
    }

    var receiverUnreadNotificationCount: Int {
        receiverNotifications.filter { !$0.isRead }.count
    }

    /// Kinds shown in the notification center (avoids noisy legacy rows).
    static let receiverUsefulNotificationKinds: Set<String> = ["newFood", "requestApproved", "dailyLimit", "systemDaily"]

    var receiverUnreadSmartNotificationCount: Int {
        receiverNotifications.filter { !$0.isRead && Self.receiverUsefulNotificationKinds.contains($0.notifKind) }.count
    }

    var receiverNotificationsFiltered: [ReceiverNotificationItem] {
        receiverNotifications.filter { Self.receiverUsefulNotificationKinds.contains($0.notifKind) }
    }

    // MARK: - Receiver control panel (mock, persisted)

    var receiverRiders: [ReceiverRider] = [] {
        didSet {
            if let data = try? JSONEncoder().encode(receiverRiders) {
                UserDefaults.standard.set(data, forKey: receiverRidersKey)
            }
        }
    }

    var receiverFoodStockLevel: ReceiverFoodStockLevel = .medium {
        didSet {
            UserDefaults.standard.set(receiverFoodStockLevel.rawValue, forKey: receiverStockLevelKey)
        }
    }

    var receiverDistributionProofs: [ReceiverDistributionProof] = [] {
        didSet {
            if let data = try? JSONEncoder().encode(receiverDistributionProofs) {
                UserDefaults.standard.set(data, forKey: receiverProofsKey)
            }
        }
    }

    var receiverCommunityReviews: [ReceiverCommunityReview] = [] {
        didSet {
            if let data = try? JSONEncoder().encode(receiverCommunityReviews) {
                UserDefaults.standard.set(data, forKey: receiverReviewsKey)
            }
        }
    }

    // MARK: - Receiver daily limit & points (separate from auth)

    /// Max meals an **individual** receiver may log per calendar day (local time).
    var receiverDailyMealLimitIndividual: Int = 20 {
        didSet { UserDefaults.standard.set(receiverDailyMealLimitIndividual, forKey: receiverDailyLimitIndividualKey) }
    }

    /// Max meals an **NGO** receiver may log per calendar day (local time).
    var receiverDailyMealLimitNGO: Int = 50 {
        didSet { UserDefaults.standard.set(receiverDailyMealLimitNGO, forKey: receiverDailyLimitNGOKey) }
    }

    /// Meals logged today toward the daily cap (resets at local midnight).
    var receiverMealsReceivedToday: Int = 0 {
        didSet { UserDefaults.standard.set(receiverMealsReceivedToday, forKey: receiverMealsTodayKey) }
    }

    /// `yyyy-MM-dd` in the current calendar, last day `receiverMealsReceivedToday` was reset for.
    private(set) var receiverEconomyLastResetDayId: String = "" {
        didSet { UserDefaults.standard.set(receiverEconomyLastResetDayId, forKey: receiverLastResetDayKey) }
    }

    /// Lifetime points — redeemable later for rewards (mock).
    var receiverTotalPoints: Int = 0 {
        didSet { UserDefaults.standard.set(receiverTotalPoints, forKey: receiverTotalPointsKey) }
    }

    /// Points earned per meal claimed (configurable).
    var receiverPointsPerMeal: Int = 10 {
        didSet { UserDefaults.standard.set(receiverPointsPerMeal, forKey: receiverPointsPerMealKey) }
    }

    /// All-time meals received (mock aggregate).
    var receiverLifetimeMealsReceived: Int = 0 {
        didSet { UserDefaults.standard.set(receiverLifetimeMealsReceived, forKey: receiverLifetimeMealsKey) }
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
        if let avatar = UserDefaults.standard.string(forKey: receiverAvatarSymbolKey), !avatar.isEmpty {
            receiverAvatarSymbol = avatar
        }
        if let bio = UserDefaults.standard.string(forKey: receiverBioKey), !bio.isEmpty {
            receiverBio = bio
        }
        if let data = UserDefaults.standard.data(forKey: receiverClaimsKey),
           let decoded = try? JSONDecoder().decode([ReceiverClaimRecord].self, from: data) {
            receiverClaimHistory = decoded
        } else {
            seedReceiverClaimHistory()
        }
        if let data = UserDefaults.standard.data(forKey: receiverNotificationsKey),
           let decoded = try? JSONDecoder().decode([ReceiverNotificationItem].self, from: data) {
            receiverNotifications = decoded
        } else {
            seedReceiverNotifications()
        }
        if let data = UserDefaults.standard.data(forKey: receiverRidersKey),
           let decoded = try? JSONDecoder().decode([ReceiverRider].self, from: data) {
            receiverRiders = decoded
        }
        if let raw = UserDefaults.standard.string(forKey: receiverStockLevelKey),
           let level = ReceiverFoodStockLevel(rawValue: raw) {
            receiverFoodStockLevel = level
        }
        if let data = UserDefaults.standard.data(forKey: receiverProofsKey),
           let decoded = try? JSONDecoder().decode([ReceiverDistributionProof].self, from: data) {
            receiverDistributionProofs = decoded
        }
        if let data = UserDefaults.standard.data(forKey: receiverReviewsKey),
           let decoded = try? JSONDecoder().decode([ReceiverCommunityReview].self, from: data) {
            receiverCommunityReviews = decoded
        }
        let dInd = UserDefaults.standard.object(forKey: receiverDailyLimitIndividualKey) as? Int
        receiverDailyMealLimitIndividual = dInd ?? 20
        let dNgo = UserDefaults.standard.object(forKey: receiverDailyLimitNGOKey) as? Int
        receiverDailyMealLimitNGO = dNgo ?? 50
        receiverMealsReceivedToday = UserDefaults.standard.integer(forKey: receiverMealsTodayKey)
        receiverEconomyLastResetDayId = UserDefaults.standard.string(forKey: receiverLastResetDayKey) ?? ""
        receiverTotalPoints = UserDefaults.standard.integer(forKey: receiverTotalPointsKey)
        let ppm = UserDefaults.standard.object(forKey: receiverPointsPerMealKey) as? Int
        receiverPointsPerMeal = ppm ?? 10
        receiverLifetimeMealsReceived = UserDefaults.standard.integer(forKey: receiverLifetimeMealsKey)
        if receiverEconomyLastResetDayId.isEmpty {
            receiverEconomyLastResetDayId = Self.localCalendarDayId(for: Date())
        }
        resetReceiverDailyProgressIfNeeded()
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

    private func seedReceiverClaimHistory() {
        let now = Date()
        receiverClaimHistory = [
            ReceiverClaimRecord(
                id: UUID(),
                title: "Vegetable meal boxes",
                quantityText: "12 plates",
                pointsUsed: 40,
                claimedAt: now.addingTimeInterval(-2 * 86400)
            ),
            ReceiverClaimRecord(
                id: UUID(),
                title: "Rice and dal packs",
                quantityText: "8 kg",
                pointsUsed: 28,
                claimedAt: now.addingTimeInterval(-5 * 86400)
            ),
            ReceiverClaimRecord(
                id: UUID(),
                title: "Fruit and bread combo",
                quantityText: "15 packs",
                pointsUsed: 34,
                claimedAt: now.addingTimeInterval(-8 * 86400)
            ),
        ]
    }

    private func seedReceiverNotifications() {
        let now = Date()
        receiverNotifications = [
            ReceiverNotificationItem(
                id: UUID(),
                donorName: "Green Grove Cafe",
                foodDetails: "New food available — 15 vegetarian meal boxes",
                location: "Koramangala 5th Block",
                createdAt: now.addingTimeInterval(-2 * 60),
                isRead: false,
                category: "donor",
                notifKind: "newFood"
            ),
            ReceiverNotificationItem(
                id: UUID(),
                donorName: "Program update",
                foodDetails: "Your pickup request was approved.",
                location: "You can schedule pickup in the Feed.",
                createdAt: now.addingTimeInterval(-45 * 60),
                isRead: false,
                category: "donor",
                notifKind: "requestApproved"
            ),
        ]
    }

    func markAllReceiverNotificationsRead() {
        guard receiverUnreadNotificationCount > 0 else { return }
        receiverNotifications = receiverNotifications.map {
            ReceiverNotificationItem(
                id: $0.id,
                donorName: $0.donorName,
                foodDetails: $0.foodDetails,
                location: $0.location,
                createdAt: $0.createdAt,
                isRead: true,
                category: $0.category,
                notifKind: $0.notifKind
            )
        }
    }

    // MARK: - Receiver economy

    static let receiverDailyProgressNotificationID = UUID(uuidString: "C0FFEE00-0000-4000-8000-000000000001")!

    static func localCalendarDayId(for date: Date) -> String {
        let cal = Calendar.current
        let y = cal.component(.year, from: date)
        let m = cal.component(.month, from: date)
        let d = cal.component(.day, from: date)
        return String(format: "%04d-%02d-%02d", y, m, d)
    }

    func receiverDailyLimit(isNGO: Bool) -> Int {
        isNGO ? receiverDailyMealLimitNGO : receiverDailyMealLimitIndividual
    }

    func resetReceiverDailyProgressIfNeeded() {
        let today = Self.localCalendarDayId(for: Date())
        if receiverEconomyLastResetDayId != today {
            receiverMealsReceivedToday = 0
            receiverEconomyLastResetDayId = today
        }
    }

    func remainingDailyMeals(isNGO: Bool) -> Int {
        resetReceiverDailyProgressIfNeeded()
        let cap = receiverDailyLimit(isNGO: isNGO)
        return max(0, cap - receiverMealsReceivedToday)
    }

    func isReceiverDailyLimitReached(isNGO: Bool) -> Bool {
        remainingDailyMeals(isNGO: isNGO) == 0 && receiverDailyLimit(isNGO: isNGO) > 0
    }

    /// Records meals toward today's cap; awards points. Returns an error message if over limit.
    @discardableResult
    func recordReceiverMealClaim(meals: Int, foodTitle: String, isNGO: Bool) -> String? {
        guard meals > 0 else { return nil }
        resetReceiverDailyProgressIfNeeded()
        let cap = receiverDailyLimit(isNGO: isNGO)
        if receiverMealsReceivedToday + meals > cap {
            upsertReceiverDailyProgressNotification(isNGO: isNGO)
            postDailyLimitReachedNotificationIfNeeded()
            return "Daily limit reached. Please try again tomorrow."
        }
        receiverMealsReceivedToday += meals
        let earned = meals * receiverPointsPerMeal
        receiverTotalPoints += earned
        receiverLifetimeMealsReceived += meals

        let qtyLabel = "\(meals) meals"
        let record = ReceiverClaimRecord(
            id: UUID(),
            title: foodTitle,
            quantityText: qtyLabel,
            pointsUsed: earned,
            claimedAt: Date()
        )
        receiverClaimHistory.insert(record, at: 0)

        upsertReceiverDailyProgressNotification(isNGO: isNGO)
        return nil
    }

    /// Keeps a single “daily allowance” row in the notification list (also shown as a summary card in UI).
    func upsertReceiverDailyProgressNotification(isNGO: Bool) {
        resetReceiverDailyProgressIfNeeded()
        let cap = receiverDailyLimit(isNGO: isNGO)
        let used = receiverMealsReceivedToday
        let remaining = max(0, cap - used)
        let footer: String
        if used >= cap {
            footer = "Daily limit reached. Please try again tomorrow."
        } else {
            footer = "Points are saved for future rewards and benefits."
        }
        let details = "Daily limit: \(cap) meals · Used \(used) of \(cap) today · Remaining: \(remaining). Total points: \(receiverTotalPoints)."
        let item = ReceiverNotificationItem(
            id: Self.receiverDailyProgressNotificationID,
            donorName: "Daily allowance",
            foodDetails: details,
            location: footer,
            createdAt: Date(),
            isRead: false,
            category: "system",
            notifKind: "systemDaily"
        )
        if let idx = receiverNotifications.firstIndex(where: { $0.id == Self.receiverDailyProgressNotificationID }) {
            receiverNotifications[idx] = item
        } else {
            receiverNotifications.insert(item, at: 0)
        }
    }

    /// One “daily limit reached” alert per calendar day (reduces spam).
    func postDailyLimitReachedNotificationIfNeeded() {
        let day = Self.localCalendarDayId(for: Date())
        if UserDefaults.standard.string(forKey: lastDailyLimitNotifDayKey) == day { return }
        UserDefaults.standard.set(day, forKey: lastDailyLimitNotifDayKey)
        let item = ReceiverNotificationItem(
            donorName: "Daily limit",
            foodDetails: "You’ve used all meals allowed for today.",
            location: "Daily limit reached. Please try again tomorrow.",
            createdAt: Date(),
            isRead: false,
            category: "system",
            notifKind: "dailyLimit"
        )
        receiverNotifications.insert(item, at: 0)
    }

    func postRequestApprovedNotification(summary: String = "Your pickup request was approved.") {
        let item = ReceiverNotificationItem(
            donorName: "Pickup status",
            foodDetails: summary,
            location: "Check the Feed for timing and location.",
            createdAt: Date(),
            isRead: false,
            category: "donor",
            notifKind: "requestApproved"
        )
        receiverNotifications.insert(item, at: 0)
    }

    func receiverProofs(forDonationId id: UUID) -> [ReceiverDistributionProof] {
        receiverDistributionProofs.filter { $0.donationId == id }
    }

    func receiverReviews(forDonationId id: UUID) -> [ReceiverCommunityReview] {
        receiverCommunityReviews.filter { $0.donationId == id }
    }

    func upsertReceiverRider(_ rider: ReceiverRider) {
        if let i = receiverRiders.firstIndex(where: { $0.id == rider.id }) {
            receiverRiders[i] = rider
        } else {
            receiverRiders.append(rider)
        }
    }

    func deleteReceiverRider(id: UUID) {
        receiverRiders.removeAll { $0.id == id }
    }

    func addReceiverDistributionProof(donationId: UUID?, caption: String, mediaKind: String, attachmentStub: String) {
        let proof = ReceiverDistributionProof(
            id: UUID(),
            donationId: donationId,
            caption: caption,
            mediaKind: mediaKind,
            attachmentStub: attachmentStub,
            createdAt: Date()
        )
        receiverDistributionProofs.insert(proof, at: 0)
    }

    func addReceiverCommunityReview(donationId: UUID?, authorName: String, reviewText: String, mediaNote: String) {
        let r = ReceiverCommunityReview(
            id: UUID(),
            donationId: donationId,
            authorName: authorName,
            reviewText: reviewText,
            mediaNote: mediaNote,
            createdAt: Date()
        )
        receiverCommunityReviews.insert(r, at: 0)
    }

    private func appendNewFoodAvailableNotification(for donation: Donation) {
        let item = ReceiverNotificationItem(
            donorName: kitchenDisplayName,
            foodDetails: "New food available — \(donation.foodName)",
            location: donation.pickupLocation,
            createdAt: Date(),
            isRead: false,
            category: "donor",
            notifKind: "newFood"
        )
        receiverNotifications.insert(item, at: 0)
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
        if userRole == .donor {
            appendNewFoodAvailableNotification(for: donation)
        }
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
