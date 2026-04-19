//
//  ReceiverExperience.swift
//  NGO & Individual receiver shell (4 tabs).
//

import SwiftUI

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
    @State private var showSignIn = false

    private var available: [Donation] {
        store.donations.filter(\.isActive).sorted { $0.expiry < $1.expiry }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        headerGreeting
                        liveMetricsCard
                        if session.isNGOReceiver {
                            summaryPair
                        }
                        readyForPickupSection
                        hearthFeedSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                .hearthScreenBackground()

                Button {
                    showSignIn = true
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
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.title2)
                        .foregroundStyle(HearthTokens.primary)
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
                    } label: {
                        Image(systemName: "bell.badge.fill")
                            .foregroundStyle(HearthTokens.primary)
                    }
                }
            }
            .sheet(isPresented: $showMap) {
                DonationsMapView().environment(store)
            }
            .sheet(isPresented: $showSignIn) {
                AuthSignInView()
                    .environment(store)
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
            smallMetricCard(icon: "person.3.fill", tint: HearthColor.peach, value: "24", title: "active volunteers")
        }
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
            feedRow(icon: "megaphone.fill", tint: HearthColor.peach, tag: "ANNOUNCEMENT", title: "New Cold Storage Available", subtitle: "Industrial refrigerators now online for perishable rescues.", time: "3 HOURS AGO")
            feedRow(icon: "hands.sparkles.fill", tint: HearthTokens.mintTint, tag: "COMMUNITY", title: "Volunteer Drive Success", subtitle: "Twelve new drivers joined weekend routes.", time: "5 HOURS AGO")
        }
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
    @Environment(DonationStore.self) private var store
    @Environment(AppSession.self) private var session

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if session.isNGOReceiver {
                        Text("INSTITUTIONAL DASHBOARD")
                            .font(HearthFont.labelCaps(11))
                            .foregroundStyle(HearthTokens.secondary)
                        Text("Mission Impact")
                            .font(HearthFont.display(28, weight: .bold))
                        ngoPill
                        totalDistributedCard
                        stockCard
                        rescueAlertCard
                        recentDistributions
                    } else {
                        ContentUnavailableView("Personal dashboard", systemImage: "chart.pie.fill", description: Text("Track your claims here soon."))
                    }
                }
                .padding(20)
                .padding(.bottom, 32)
            }
            .hearthScreenBackground()
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(HearthTokens.primary)
                }
                ToolbarItem(placement: .principal) {
                    Text(HearthBrand.name)
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                        .foregroundStyle(HearthTokens.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(HearthTokens.primary)
                }
            }
            .hearthNavBar()
        }
    }

    private var ngoPill: some View {
        HStack {
            Image(systemName: "house.and.flag.fill")
            Text("Active NGO Node")
                .fontWeight(.semibold)
        }
        .font(.subheadline)
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(HearthTokens.primary, in: Capsule())
    }

    private var totalDistributedCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Total Food Distributed")
                .font(HearthFont.body(15))
                .foregroundStyle(HearthTokens.onSurfaceVariant)
            HStack(alignment: .firstTextBaseline) {
                Text("\(Int(store.totalKgDonated))")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(HearthTokens.primary)
                Text("KG")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(HearthTokens.primary)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.right")
                    Text("+12%")
                }
                .font(.caption.weight(.bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(HearthTokens.mintTint, in: Capsule())
                .foregroundStyle(HearthTokens.primary)
            }
            weekBarChart
        }
        .padding(20)
        .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous))
        .hearthAmbientShadow()
    }

    private var weekBarChart: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"], id: \.self) { day in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(barColor(day))
                        .frame(width: 28, height: barHeight(day))
                    Text(day.prefix(1))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(HearthTokens.onSurfaceVariant)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private func barHeight(_ day: String) -> CGFloat {
        if day == "THU" { return 80 }
        if day == "SUN" { return 52 }
        return 36
    }

    private func barColor(_ day: String) -> Color {
        if day == "THU" { return HearthTokens.primary }
        if day == "SUN" { return HearthTokens.secondary }
        return HearthTokens.surfaceContainerLow
    }

    private var stockCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Current Stock")
                    .font(HearthFont.display(17, weight: .bold))
                Spacer()
                Image(systemName: "trash")
                    .foregroundStyle(HearthTokens.onSurfaceVariant)
            }
            stockRow("150 Meals", 0.85)
            stockRow("45kg Grains", 0.4)
            stockRow("20kg Vegetables", 0.15)
            Button {
            } label: {
                Label("Update Inventory", systemImage: "pencil")
                    .font(HearthFont.body(15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(HearthTokens.surfaceContainerLow, in: Capsule())
            }
        }
        .padding(18)
        .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous))
        .hearthAmbientShadow()
    }

    private func stockRow(_ title: String, _ p: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(HearthTokens.surfaceContainerLow)
                    Capsule()
                        .fill(p > 0.5 ? HearthTokens.primary : HearthTokens.secondary)
                        .frame(width: geo.size.width * p)
                }
            }
            .frame(height: 8)
        }
    }

    private var rescueAlertCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("New Rescue?")
                .font(HearthFont.display(18, weight: .bold))
            Text("A delivery from ‘Green Grove Cafe’ is ready for pickup.")
                .font(.subheadline)
                .foregroundStyle(HearthTokens.onSurface)
            Button {
            } label: {
                Text("Accept Pickup")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.78), in: Capsule())
                    .foregroundStyle(.white)
            }
        }
        .padding(18)
        .background(HearthTokens.secondary.opacity(0.92), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: "shippingbox.fill")
                .font(.largeTitle)
                .foregroundStyle(.black.opacity(0.08))
                .padding(12)
        }
    }

    private var recentDistributions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Distributions")
                    .font(HearthFont.display(17, weight: .bold))
                Spacer()
                Text("View History →")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(HearthTokens.primary)
            }
            distributionRow("Unity Shelters", "HUMAN", "District 4 · 85 meals", true)
            distributionRow("Paws & Claws Refuge", "ANIMAL", "Sanctuary · 32 scraps", false)
        }
        .padding(18)
        .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous))
        .hearthAmbientShadow()
    }

    private func distributionRow(_ name: String, _ chip: String, _ sub: String, _ human: Bool) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(HearthTokens.surfaceContainerLow)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "building.fill")
                        .font(.caption)
                }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.subheadline.weight(.bold))
                    Text(chip)
                        .font(HearthFont.labelCaps(8))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(human ? HearthTokens.mintTint : HearthColor.peach.opacity(0.8), in: Capsule())
                }
                Text(sub)
                    .font(.caption)
                    .foregroundStyle(HearthTokens.onSurfaceVariant)
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Feed

struct ReceiverFeedTab: View {
    @Environment(DonationStore.self) private var store
    @State private var filter = "All Food"

    private let filters = ["All Food", "Human", "Pet"]

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Label(HearthBrand.name, systemImage: "mappin.circle.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(HearthTokens.onSurface)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(HearthTokens.primary)
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
    @Environment(DonationStore.self) private var store
    @Environment(AppSession.self) private var session
    @Environment(ReceiverAuthManager.self) private var receiverAuth

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(HearthTokens.mintTint)
                            .frame(width: 100, height: 100)
                            .overlay {
                                Image(systemName: session.isNGOReceiver ? "building.2.fill" : "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(HearthTokens.primary)
                            }
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(HearthTokens.primary)
                            .background(Circle().fill(HearthTokens.surfaceContainerLowest).padding(2))
                    }
                    Text(store.receiverProfileName)
                        .font(HearthFont.display(22, weight: .bold))

                    if let kind = receiverAuth.currentKind {
                        Text(kind == .ngo ? "NGO account" : "Individual account")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(HearthTokens.onSurfaceVariant)
                    }

                    if let id = receiverAuth.currentIdentifier {
                        Label(id, systemImage: id.contains("@") ? "envelope.fill" : "phone.fill")
                            .font(.subheadline)
                            .foregroundStyle(HearthTokens.onSurfaceVariant)
                    }

                    Label(store.receiverCity, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundStyle(HearthTokens.onSurfaceVariant)

                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.orange)
                        Text("VERIFIED PARTNER")
                            .font(HearthFont.labelCaps(11))
                            .foregroundStyle(HearthTokens.primary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(HearthTokens.mintTint, in: Capsule())

                    Button {
                        receiverAuth.logout()
                        session.returnToReceiverOnboarding()
                    } label: {
                        Text("Sign out")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(HearthTokens.surfaceContainerLow, in: Capsule())
                            .foregroundStyle(HearthTokens.primary)
                    }

                    Button {
                        receiverAuth.logout()
                        session.returnToLanding()
                    } label: {
                        Text("Exit to welcome")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(HearthTokens.secondary)
                    }
                }
                .padding(24)
            }
            .hearthScreenBackground()
            .navigationTitle("Profile")
            .hearthNavBar()
        }
    }
}
