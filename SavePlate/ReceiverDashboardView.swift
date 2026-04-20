//
//  ReceiverDashboardView.swift
//  SavePlate — receiver dashboard (NGO + Individual), daily limits, points, sidebar.
//

import SwiftUI

enum ReceiverDashboardRoute: Hashable {
    case notifications
    case profile
    case history
}

struct ReceiverDashboardView: View {
    @Environment(DonationStore.self) private var store
    @Environment(AppSession.self) private var session

    @Binding var path: NavigationPath
    @Binding var showSidebar: Bool

    @AppStorage("hearth.receiver.lastDashboardPromptDay") private var lastDashboardPromptDay: String = ""
    @State private var showDailyWelcomeAlert = false

    private var isNGO: Bool { session.isNGOReceiver }
    private var dailyCap: Int { store.receiverDailyLimit(isNGO: isNGO) }
    private var usedToday: Int { store.receiverMealsReceivedToday }
    private var progress: CGFloat {
        guard dailyCap > 0 else { return 0 }
        return min(1, CGFloat(usedToday) / CGFloat(dailyCap))
    }

    var body: some View {
        ZStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if isNGO {
                        Text("INSTITUTIONAL DASHBOARD")
                            .font(HearthFont.labelCaps(11))
                            .foregroundStyle(HearthTokens.secondary)
                        Text("Mission Impact")
                            .font(HearthFont.display(28, weight: .bold))
                        ngoPill
                    } else {
                        Text("YOUR DASHBOARD")
                            .font(HearthFont.labelCaps(11))
                            .foregroundStyle(HearthTokens.secondary)
                        Text("Rescue overview")
                            .font(HearthFont.display(28, weight: .bold))
                    }

                    dailyLimitCard
                    pointsSummaryCard

                    if isNGO {
                        totalDistributedCard
                        stockCard
                        rescueAlertCard
                        recentDistributions
                    } else {
                        individualImpactCard
                    }
                }
                .padding(20)
                .padding(.bottom, 32)
            }
            .hearthScreenBackground()

            if showSidebar {
                sidebarOverlay
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showSidebar = true
                    }
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(HearthTokens.primary)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(HearthBrand.name)
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .foregroundStyle(HearthTokens.primary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    path.append(ReceiverDashboardRoute.notifications)
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(HearthTokens.primary)
                        if store.receiverUnreadNotificationCount > 0 {
                            Text("\(min(store.receiverUnreadNotificationCount, 9))")
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
        .hearthNavBar()
        .onAppear {
            store.resetReceiverDailyProgressIfNeeded()
            store.upsertReceiverDailyProgressNotification(isNGO: isNGO)
            let today = DonationStore.localCalendarDayId(for: Date())
            if lastDashboardPromptDay != today {
                lastDashboardPromptDay = today
                showDailyWelcomeAlert = true
            }
        }
        .alert("Your daily rescue allowance", isPresented: $showDailyWelcomeAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(dailyWelcomeMessage)
        }
    }

    private var dailyWelcomeMessage: String {
        let cap = dailyCap
        let used = usedToday
        if used >= cap {
            return "You have a daily limit of \(cap) meals. You have used \(used) of \(cap) meals today. Daily limit reached. Please try again tomorrow."
        }
        return "You have a daily limit of \(cap) meals. You have used \(used) of \(cap) meals today. Points you earn can be used later for rewards."
    }

    private var sidebarOverlay: some View {
        ZStack(alignment: .leading) {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showSidebar = false
                    }
                }

            ReceiverSidebarMenuView(path: $path) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showSidebar = false
                }
            }
            .frame(width: 286)
            .frame(maxHeight: .infinity, alignment: .leading)
            .background(HearthTokens.surfaceContainerLowest)
            .transition(.move(edge: .leading))
        }
    }

    // MARK: - Daily limit & points

    private var dailyLimitCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today’s meal allowance")
                .font(HearthFont.display(17, weight: .bold))
            Text("You can log up to \(dailyCap) meals per day. Resets at midnight.")
                .font(.caption)
                .foregroundStyle(HearthTokens.onSurfaceVariant)
            HStack(alignment: .firstTextBaseline) {
                Text("\(usedToday)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(HearthTokens.primary)
                Text("of \(dailyCap) meals")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(store.remainingDailyMeals(isNGO: isNGO)) left")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(HearthTokens.mintTint, in: Capsule())
                    .foregroundStyle(HearthTokens.primary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(HearthTokens.surfaceContainerLow)
                    Capsule()
                        .fill(store.isReceiverDailyLimitReached(isNGO: isNGO) ? HearthTokens.secondary : HearthTokens.primary)
                        .frame(width: max(8, geo.size.width * progress))
                }
            }
            .frame(height: 10)
            if store.isReceiverDailyLimitReached(isNGO: isNGO) {
                Text("Daily limit reached. Please try again tomorrow.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(HearthTokens.secondary)
            }
        }
        .padding(18)
        .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous))
        .hearthAmbientShadow()
    }

    private var pointsSummaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hearth points")
                .font(HearthFont.display(17, weight: .bold))
            Text("Earn \(store.receiverPointsPerMeal) points per meal — redeem later for discounts and benefits.")
                .font(.caption)
                .foregroundStyle(HearthTokens.onSurfaceVariant)
            HStack {
                Label("\(store.receiverTotalPoints) pts", systemImage: "star.circle.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(HearthTokens.secondary)
                Spacer()
                Text("Lifetime meals: \(store.receiverLifetimeMealsReceived)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(HearthTokens.onSurfaceVariant)
            }
        }
        .padding(18)
        .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous)
                .stroke(HearthTokens.primary.opacity(0.12), lineWidth: 1)
        )
    }

    private var individualImpactCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Community impact")
                .font(HearthFont.display(17, weight: .bold))
            Text("Every claim you complete helps neighbors access safe surplus food. Keep your profile updated so donors can trust your pickups.")
                .font(.subheadline)
                .foregroundStyle(HearthTokens.onSurfaceVariant)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous))
        .hearthAmbientShadow()
    }

    // MARK: - NGO sections (existing layout)

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

// MARK: - Sidebar

struct ReceiverSidebarMenuView: View {
    @Environment(DonationStore.self) private var store
    @Environment(AppSession.self) private var session
    @Environment(ReceiverAuthManager.self) private var receiverAuth

    @Binding var path: NavigationPath
    var onClose: () -> Void

    private var isNGO: Bool { session.isNGOReceiver }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Menu")
                    .font(HearthFont.display(22, weight: .bold))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Total points")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(HearthTokens.onSurfaceVariant)
                    Text("\(store.receiverTotalPoints)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(HearthTokens.secondary)
                    Text("Saved for future rewards")
                        .font(.caption)
                        .foregroundStyle(HearthTokens.onSurfaceVariant)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Meals today")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(HearthTokens.onSurfaceVariant)
                    Text("\(store.receiverMealsReceivedToday) / \(store.receiverDailyLimit(isNGO: isNGO))")
                        .font(.title3.weight(.bold))
                    GeometryReader { geo in
                        let cap = store.receiverDailyLimit(isNGO: isNGO)
                        let p = cap > 0 ? CGFloat(store.receiverMealsReceivedToday) / CGFloat(cap) : 0
                        ZStack(alignment: .leading) {
                            Capsule().fill(HearthTokens.surfaceContainerLow)
                            Capsule()
                                .fill(HearthTokens.primary)
                                .frame(width: max(6, geo.size.width * min(1, p)))
                        }
                    }
                    .frame(height: 8)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Lifetime meals received")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(HearthTokens.onSurfaceVariant)
                    Text("\(store.receiverLifetimeMealsReceived)")
                        .font(.title3.weight(.bold))
                }

                Divider()

                sidebarButton(title: "Profile", icon: "person.fill") {
                    path.append(ReceiverDashboardRoute.profile)
                    onClose()
                }
                sidebarButton(title: "History", icon: "clock.arrow.circlepath") {
                    path.append(ReceiverDashboardRoute.history)
                    onClose()
                }

                Button(role: .destructive) {
                    receiverAuth.logout()
                    session.returnToReceiverOnboarding()
                    onClose()
                } label: {
                    Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                }
            }
            .padding(20)
        }
    }

    private func sidebarButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .foregroundStyle(HearthTokens.onSurface)
    }
}

private struct ReceiverDashboardPreviewHost: View {
    @State private var path = NavigationPath()
    @State private var showSidebar = false

    var body: some View {
        NavigationStack {
            ReceiverDashboardView(path: $path, showSidebar: $showSidebar)
                .environment(DonationStore())
                .environment(AppSession())
                .environment(ReceiverAuthManager())
        }
    }
}

#Preview {
    ReceiverDashboardPreviewHost()
}
