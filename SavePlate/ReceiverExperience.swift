//
//  ReceiverExperience.swift
//  NGO & Individual receiver shell (4 tabs).
//

import SwiftUI

private enum ReceiverHomeRoute: Hashable {
    case profile
    case notifications
    case addVolunteer
    case volunteers
}

struct ReceiverRootTabView: View {
    @Environment(DonationStore.self) private var store
    @Environment(AppSession.self) private var session

    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            ReceiverHomeTab()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            ReceiverDashboardTab()
                .tabItem { Label("Dashboard", systemImage: "square.grid.2x2.fill") }
                .tag(1)

            ReceiverFeedTab()
                .tabItem { Label("Feed", systemImage: "rectangle.stack.fill") }
                .tag(2)

            ReceiverProfileTab()
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(3)
        }
        .tint(HearthTokens.primary)
        .hearthTabBar()
    }
}

// MARK: - Home

struct ReceiverHomeTab: View {
    @Environment(DonationStore.self) private var store
    @Environment(AppSession.self) private var session

    @State private var showMap = false
    @State private var routePath = NavigationPath()

    private var available: [Donation] {
        store.donations.filter(\.isActive).sorted { $0.expiry < $1.expiry }
    }

    var body: some View {
        NavigationStack(path: $routePath) {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        headerGreeting
                        liveMetricsCard
                        if session.isNGOReceiver {
                            summaryPair
                        }
                        activeVolunteersSection
                        readyForPickupSection
                        hearthFeedSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                .hearthScreenBackground()

                Button {
                    routePath.append(ReceiverHomeRoute.addVolunteer)
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(HearthTokens.secondary, in: Circle())
                        .hearthAmbientShadow()
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .navigationDestination(for: Donation.self) { d in
                ReceiverDonationDetailView(donation: d)
            }
            .navigationDestination(for: ReceiverHomeRoute.self) { route in
                switch route {
                case .profile:
                    ReceiverProfileView()
                case .notifications:
                    ReceiverNotificationsView()
                case .addVolunteer:
                    AddVolunteerView()
                case .volunteers:
                    VolunteerListView()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        routePath.append(ReceiverHomeRoute.profile)
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title2)
                            .foregroundStyle(HearthTokens.primary)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(HearthBrand.name)
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                        .foregroundStyle(HearthTokens.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        routePath.append(ReceiverHomeRoute.notifications)
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.badge.fill")
                                .foregroundStyle(HearthTokens.primary)
                            if store.receiverUnreadSmartNotificationCount > 0 {
                                Text("\(min(store.receiverUnreadSmartNotificationCount, 9))")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(4)
                                    .background(Color.red, in: Circle())
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showMap) {
                DonationsMapView().environment(store)
            }
            .hearthNavBar()
        }
    }

    private var headerGreeting: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greetingPrefix + ", \(store.receiverProfileName).")
                .font(HearthFont.display(26, weight: .bold))
                .foregroundStyle(HearthTokens.onSurface)
            Text("Your efforts today are making a world of difference.")
                .font(HearthFont.body(15))
                .foregroundStyle(HearthTokens.onSurfaceVariant)
        }
        .padding(.top, 8)
    }

    private var greetingPrefix: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    private var liveMetricsCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous)
                .fill(HearthGradient.pulseGreen)
            VStack(alignment: .leading, spacing: 12) {
                Text("LIVE METRICS")
                    .font(HearthFont.labelCaps(10))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.2), in: Capsule())
                    .foregroundStyle(.white)
                Text("\(store.mealsSavedThisCalendarMonth)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Meals Rescued Today")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.92))
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.right.circle.fill")
                    Text("12% more than yesterday")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.15), in: Capsule())
            }
            .padding(20)
            Image(systemName: "leaf.fill")
                .font(.system(size: 80))
                .foregroundStyle(.white.opacity(0.12))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(20)
        }
        .frame(minHeight: 180)
    }

    private var summaryPair: some View {
        HStack(spacing: 12) {
            smallMetricCard(icon: "mappin.circle.fill", tint: HearthTokens.mintTint, value: "12.4 km", title: "to pickups")
            smallMetricCard(icon: "person.3.fill", tint: HearthColor.peach, value: "\(store.activeReceiverVolunteersCount)", title: "active volunteers")
        }
    }

    private var activeVolunteersSection: some View {
        Button {
            routePath.append(ReceiverHomeRoute.volunteers)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Active Volunteers")
                        .font(HearthFont.display(18, weight: .bold))
                        .foregroundStyle(HearthTokens.onSurface)
                    Spacer()
                    Label("\(store.activeReceiverVolunteersCount)", systemImage: "person.2.fill")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(HearthTokens.surfaceContainerLow, in: Capsule())
                        .foregroundStyle(HearthTokens.primary)
                }
                HStack(spacing: 8) {
                    if store.receiverVolunteersSorted.isEmpty {
                        Text("No volunteers yet. Tap + to add local helpers.")
                            .font(.subheadline)
                            .foregroundStyle(HearthTokens.onSurfaceVariant)
                    } else {
                        ForEach(store.receiverVolunteersSorted.prefix(4)) { volunteer in
                            volunteerAvatar(
                                imageData: volunteer.imageData,
                                status: volunteer.status,
                                size: 36
                            )
                        }
                        if store.receiverVolunteersSorted.count > 4 {
                            Text("+\(store.receiverVolunteersSorted.count - 4)")
                                .font(.caption.weight(.bold))
                                .frame(width: 36, height: 36)
                                .background(HearthTokens.primary, in: Circle())
                                .foregroundStyle(.white)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(HearthTokens.onSurfaceVariant)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .hearthAmbientShadow()
        }
        .buttonStyle(.plain)
    }

    private func smallMetricCard(icon: String, tint: Color, value: String, title: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(tint)
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundStyle(HearthTokens.primary)
            }
            Text(value)
                .font(HearthFont.display(20, weight: .bold))
            Text(title)
                .font(.caption)
                .foregroundStyle(HearthTokens.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .hearthAmbientShadow()
    }

    private var readyForPickupSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Ready for Pickup")
                    .font(HearthFont.display(18, weight: .bold))
                Spacer()
                Button {
                    showMap = true
                } label: {
                    Text("View map")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(HearthTokens.primary)
                }
            }
            if available.isEmpty {
                Text("No listings right now. Check the Feed tab.")
                    .font(.subheadline)
                    .foregroundStyle(HearthTokens.onSurfaceVariant)
            } else {
                ForEach(available.prefix(4)) { d in
                    NavigationLink(value: d) {
                        pickupCard(d)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func pickupCard(_ d: Donation) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(HearthTokens.surfaceContainerLow)
                    .frame(height: 120)
                Image(systemName: "leaf.fill")
                    .font(.largeTitle)
                    .foregroundStyle(HearthTokens.primary.opacity(0.3))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Text("EXPIRES IN 2H")
                    .font(HearthFont.labelCaps(9))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(HearthTokens.secondary.opacity(0.95), in: Capsule())
                    .foregroundStyle(.white)
                    .padding(10)
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(d.foodName)
                        .font(HearthFont.body(16, weight: .bold))
                    Spacer()
                    Text(quantityShort(d))
                        .font(.subheadline.weight(.semibold))
                }
                Text("Local donor · 1.2 km away")
                    .font(.caption)
                    .foregroundStyle(HearthTokens.onSurfaceVariant)
                HStack {
                    Image(systemName: "truck.box.fill")
                    Text("Claim Pickup")
                        .font(HearthFont.body(15, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(HearthTokens.primary, in: Capsule())
                .foregroundStyle(.white)
            }
            .padding(14)
        }
        .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .hearthAmbientShadow()
    }

    private func quantityShort(_ d: Donation) -> String {
        let fmt = d.unit == .plates ? "%.0f" : "%.1f"
        return String(format: fmt, d.quantity) + " " + d.unit.abbreviation
    }

    private var hearthFeedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("The Hearth Feed")
                .font(HearthFont.display(18, weight: .bold))
            stockAnnouncementRow
            feedRow(icon: "megaphone.fill", tint: HearthColor.peach, tag: "ANNOUNCEMENT", title: "New Cold Storage Available", subtitle: "Industrial refrigerators now online for perishable rescues.", time: "3 HOURS AGO")
            feedRow(icon: "hands.sparkles.fill", tint: HearthTokens.mintTint, tag: "COMMUNITY", title: "Volunteer Drive Success", subtitle: "Twelve new drivers joined weekend routes.", time: "5 HOURS AGO")
        }
    }

    private var stockAnnouncementRow: some View {
        let level = store.receiverFoodStockLevel
        let subtitle: String = {
            switch level {
            case .full: return "Pantry is well stocked — great position for the week."
            case .medium: return "Comfortable inventory — monitor high-traffic distribution days."
            case .low: return "Running low — plan pickups or prioritize portions."
            case .empty: return "Stock is empty — prioritize incoming rescues and support."
            }
        }()
        return HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(stockIndicatorColor(level.statusToken).opacity(0.25))
                    .frame(width: 44, height: 44)
                Circle()
                    .fill(stockIndicatorColor(level.statusToken))
                    .frame(width: 12, height: 12)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("STOCK STATUS")
                    .font(HearthFont.labelCaps(9))
                    .foregroundStyle(HearthTokens.secondary)
                Text("Food stock: \(level.title)")
                    .font(HearthFont.body(16, weight: .bold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(HearthTokens.onSurfaceVariant)
                Text("Updated from Control Panel")
                    .font(HearthFont.labelCaps(9))
                    .foregroundStyle(HearthTokens.onSurfaceVariant.opacity(0.8))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .hearthAmbientShadow()
    }

    private func feedRow(icon: String, tint: Color, tag: String, title: String, subtitle: String, time: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(tint).frame(width: 44, height: 44)
                Image(systemName: icon).foregroundStyle(HearthTokens.primary)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(tag)
                    .font(HearthFont.labelCaps(9))
                    .foregroundStyle(HearthTokens.secondary)
                Text(title)
                    .font(HearthFont.body(16, weight: .bold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(HearthTokens.onSurfaceVariant)
                Text(time)
                    .font(HearthFont.labelCaps(9))
                    .foregroundStyle(HearthTokens.onSurfaceVariant.opacity(0.8))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .hearthAmbientShadow()
    }
}

// MARK: - Dashboard (institutional)

struct ReceiverDashboardTab: View {
    @State private var path = NavigationPath()
    @State private var showSidebar = false

    var body: some View {
        NavigationStack(path: $path) {
            ReceiverDashboardView(path: $path, showSidebar: $showSidebar)
                .navigationDestination(for: ReceiverDashboardRoute.self) { route in
                    switch route {
                    case .notifications:
                        ReceiverNotificationsView()
                    case .profile:
                        ReceiverProfileView()
                    case .history:
                        ReceiverHistoryView()
                    }
                }
        }
    }
}

// MARK: - Feed

private enum ReceiverFeedRoute: Hashable {
    case controlPanel
    case notifications
}

struct ReceiverFeedTab: View {
    @Environment(DonationStore.self) private var store
    @State private var filter = "All Food"
    @State private var path = NavigationPath()

    private let filters = ["All Food", "Human", "Pet"]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    liveImpactMini
                    filterChips
                    ForEach(store.donations.filter(\.isActive).prefix(6)) { d in
                        NavigationLink(value: d) {
                            feedDonationCard(d)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .hearthScreenBackground()
            .navigationDestination(for: Donation.self) { d in
                ReceiverDonationDetailView(donation: d)
            }
            .navigationDestination(for: ReceiverFeedRoute.self) { route in
                switch route {
                case .controlPanel:
                    ControlPanelView()
                case .notifications:
                    ReceiverNotificationsView()
                }
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        path.append(ReceiverFeedRoute.controlPanel)
                    } label: {
                        Image(systemName: "key.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(HearthTokens.primary)
                            .frame(width: 40, height: 40)
                            .background(HearthTokens.surfaceContainerLow, in: Circle())
                    }
                    .accessibilityLabel("Control panel")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        path.append(ReceiverFeedRoute.notifications)
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(HearthTokens.primary)
                            if store.receiverUnreadSmartNotificationCount > 0 {
                                Text("\(min(store.receiverUnreadSmartNotificationCount, 9))")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(4)
                                    .background(Color.red, in: Circle())
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                    .accessibilityLabel("Notifications")
                }
            }
            .hearthNavBar()
        }
    }

    private var liveImpactMini: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LIVE IMPACT")
                .font(HearthFont.labelCaps(11))
                .foregroundStyle(HearthTokens.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("842 kg")
                    .font(HearthFont.display(32, weight: .bold))
                Text("Saved")
                    .font(HearthFont.display(32, weight: .bold))
                    .foregroundStyle(HearthTokens.primary)
            }
            Text("Resources shared in your community today.")
                .font(.subheadline)
                .foregroundStyle(HearthTokens.onSurfaceVariant)
            HStack(spacing: -8) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(HearthTokens.surfaceContainerLow)
                        .frame(width: 32, height: 32)
                        .overlay {
                            Text("👤")
                                .font(.caption)
                        }
                        .overlay(Circle().stroke(HearthTokens.surfaceContainerLowest, lineWidth: 2))
                }
                Text("+13")
                    .font(.caption.weight(.bold))
                    .frame(width: 32, height: 32)
                    .background(HearthTokens.primary, in: Circle())
                    .foregroundStyle(.white)
            }
        }
        .padding(20)
        .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous))
        .hearthAmbientShadow()
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(filters, id: \.self) { f in
                    Button {
                        filter = f
                    } label: {
                        HStack(spacing: 4) {
                            Text(f)
                            if f == "All Food" {
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                            }
                        }
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(filter == f ? HearthTokens.primary : HearthTokens.surfaceContainerLowest, in: Capsule())
                        .foregroundStyle(filter == f ? Color.white : HearthTokens.onSurface)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func feedDonationCard(_ d: Donation) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(HearthTokens.surfaceContainerLow)
                    .frame(height: 140)
                Image(systemName: "leaf.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(HearthTokens.primary.opacity(0.25))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Text("ENDS IN 2H")
                    .font(HearthFont.labelCaps(9))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(10)
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("FOR HUMANS")
                        .font(HearthFont.labelCaps(9))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(HearthTokens.mintTint, in: Capsule())
                    Text("PICKUP BY 6 PM")
                        .font(HearthFont.labelCaps(9))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(HearthTokens.surfaceContainerLow, in: Capsule())
                }
                Text(d.foodName)
                    .font(HearthFont.body(17, weight: .bold))
                Text("Surplus from a verified donor. Handle with care and keep cold chain if needed.")
                    .font(.caption)
                    .foregroundStyle(HearthTokens.onSurfaceVariant)
                    .lineLimit(3)
                Button {
                } label: {
                    Text("Claim Now")
                        .font(HearthFont.body(15, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(HearthTokens.secondary, in: Capsule())
                        .foregroundStyle(.white)
                }
            }
            .padding(14)
        }
        .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .hearthAmbientShadow()
    }
}

// MARK: - Profile

struct ReceiverProfileTab: View {
    var body: some View {
        NavigationStack {
            ReceiverProfileView()
        }
    }
}
