//
//  DonorHomeView.swift
//  SavePlate
//

import SwiftUI

struct DonorHomeView: View {
    @Environment(DonationStore.self) private var store
    @Environment(AppSession.self) private var session
    var goToDonate: () -> Void
    var goToProfile: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("WELCOME BACK")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(HearthColor.earthMuted)
                        Text(store.kitchenDisplayName)
                            .font(.system(size: 28, weight: .bold))
                        quoteBlock
                    }
                    .padding(.horizontal, 4)

                    liveImpactCard

                    recentSection

                    communityPulseCard
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 28)
            }
            .scrollContentBackground(.hidden)
            .hearthScreenBackground()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("Switch journey", role: .destructive) {
                            session.returnToLanding()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(HearthColor.forest)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(HearthBrand.name)
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                        .foregroundStyle(HearthColor.forestHeader)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: goToProfile) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(HearthColor.forest)
                    }
                }
            }
            .hearthNavBar()
        }
    }

    private var quoteBlock: some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(HearthColor.leaf)
                .frame(width: 3)
            Text("Your surplus is someone’s sustenance. Thank you for curating nourishment for our community.")
                .font(.system(size: 15, weight: .regular, design: .default))
                .italic()
                .foregroundStyle(Color(red: 0.32, green: 0.32, blue: 0.34))
        }
        .padding(.vertical, 6)
    }

    private var liveImpactCard: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(HearthGradient.liveImpactCard)

            VStack(alignment: .leading, spacing: 14) {
                Text("LIVE IMPACT")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.22), in: Capsule())
                    .foregroundStyle(.white)

                Text("\(store.mealsSavedThisCalendarMonth)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Meals Saved this Month")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.92))

                Button(action: goToDonate) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                        Text("Donate Food Now")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(HearthColor.terracotta, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)

                Text("NEXT PICKUP WINDOW: \(pickupWindowText)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            .padding(20)
        }
        .frame(minHeight: 280)
    }

    private var pickupWindowText: String {
        let active = store.donations.filter(\.isActive).sorted { $0.expiry < $1.expiry }
        guard let first = active.first else { return "2:00 PM – 4:00 PM" }
        let t = first.expiry.formatted(date: .omitted, time: .shortened)
        return "Before \(t) · \(first.pickupLocation)"
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Donations")
                    .font(.headline)
                Spacer()
                Button("View All", action: goToDonate)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(HearthColor.forest)
            }

            let recent = store.donations.sorted { $0.createdAt > $1.createdAt }.prefix(3)
            if recent.isEmpty {
                Text("No donations yet. Tap Donate Food Now to list surplus.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(recent)) { d in
                        recentDonationRow(d)
                    }
                }
            }
        }
    }

    private func recentDonationRow(_ d: Donation) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [HearthColor.mint, HearthColor.leaf.opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 72, height: 56)
                .overlay {
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(HearthColor.forest.opacity(0.6))
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(d.foodName)
                    .font(.subheadline.weight(.semibold))
                Text(quantityLine(d))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if d.isCancelled {
                Label("Cancelled", systemImage: "xmark.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            } else if d.isActive {
                Label("Active", systemImage: "checkmark.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(HearthColor.leaf)
            } else {
                Label("Completed", systemImage: "checkmark.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(HearthColor.leaf)
            }
        }
        .padding(12)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
    }

    private func quantityLine(_ d: Donation) -> String {
        let fmt = d.unit == .plates ? "%.0f" : "%.1f"
        return String(format: fmt, d.quantity) + " " + d.unit.abbreviation
    }

    private var communityPulseCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Community Pulse")
                .font(.headline)

            pulseRow(
                icon: "megaphone.fill",
                iconBg: HearthColor.peach.opacity(0.9),
                text: "Urgent Need: Proteins — St. Jude’s Shelter is seeing a spike in weekend guests."
            )
            pulseRow(
                icon: "party.popper.fill",
                iconBg: HearthColor.mintWash,
                text: "Milestone Reached! — Our district just saved its 10,000th meal of the year."
            )

            HStack {
                Text("YOUR RANK")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("#\(store.donorRankDisplay) Donor")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(HearthColor.earth)
            }
            .padding(.top, 4)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5))
                    Capsule()
                        .fill(HearthColor.terracotta)
                        .frame(width: geo.size.width * rankProgress)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    private var rankProgress: CGFloat {
        let m = min(store.totalMealsDonated, 2000)
        return CGFloat(m) / 2000.0
    }

    private func pulseRow(icon: String, iconBg: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconBg)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundStyle(HearthColor.forest)
            }
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color(red: 0.25, green: 0.25, blue: 0.28))
        }
    }
}
