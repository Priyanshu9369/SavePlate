//
//  ReceiverDonationDetailView.swift
//  Claim-focused donation detail (receiver / NGO).
//

import SwiftUI

struct ReceiverDonationDetailView: View {
    @Environment(DonationStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let donation: Donation
    @State private var isClaimed = false

    private var live: Donation? { store.donations.first { $0.id == donation.id } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroImage

                VStack(alignment: .leading, spacing: 16) {
                    if let d = live {
                        Text(d.foodName)
                            .font(HearthFont.display(26, weight: .bold))
                            .foregroundStyle(HearthTokens.onSurface)
                            .padding(.horizontal, 4)

                        infoGrid(d)

                        aboutSection(d)

                       // tagsSection(d)

                        donorCard

                        pickupMapSection(d)
                    } else {
                        ContentUnavailableView("Unavailable", systemImage: "tray", description: Text("This rescue is no longer listed."))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
        }
        .ignoresSafeArea(edges: .top)
        .hearthScreenBackground()
        .navigationTitle("Donation Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    Button {
                    } label: {
                        Image(systemName: "heart")
                    }
                }
                .foregroundStyle(HearthTokens.primary)
            }
        }
        .safeAreaInset(edge: .bottom) {
            claimBar
        }
    }

    private var heroImage: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [HearthTokens.mintTint, HearthTokens.surfaceContainerLow],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 240)
            .overlay {
                Image(systemName: "photo.fill.on.rectangle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(HearthTokens.primary.opacity(0.25))
            }

            Text("FRESHLY BAKED")
                .font(HearthFont.labelCaps(10))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(HearthTokens.secondary.opacity(0.95), in: Capsule())
                .foregroundStyle(.white)
                .padding(16)
        }
    }

    private func infoGrid(_ d: Donation) -> some View {
        VStack(spacing: 12) {
            infoRow(icon: "cube.box.fill", label: "QUANTITY", value: quantityText(d), tint: HearthTokens.primary)
            infoRow(icon: "clock.fill", label: "EXPIRES IN", value: timeRemaining(d), tint: HearthTokens.secondary)
            infoRow(icon: "location.north.line", label: "DISTANCE", value: "0.8 mi", tint: HearthTokens.primary)
        }
    }

    private func infoRow(icon: String, label: String, value: String, tint: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(HearthTokens.surfaceContainerLow)
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .foregroundStyle(tint)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(HearthFont.labelCaps(10))
                    .foregroundStyle(HearthTokens.onSurfaceVariant)
                Text(value)
                    .font(HearthFont.display(17, weight: .bold))
                    .foregroundStyle(HearthTokens.onSurface)
            }
            Spacer()
        }
        .padding(16)
        .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous))
        .hearthAmbientShadow()
    }

    private func quantityText(_ d: Donation) -> String {
        let fmt = d.unit == .plates ? "%.0f" : "%.1f"
        return String(format: fmt, d.quantity) + " " + d.unit.abbreviation
    }

    private func timeRemaining(_ d: Donation) -> String {
        let s = d.expiry.timeIntervalSinceNow
        if s <= 0 { return "Expired" }
        let m = Int(s / 60)
        return "\(m) min"
    }

    private func aboutSection(_ d: Donation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About this rescue")
                .font(HearthFont.display(20, weight: .bold))
            Text(d.notes.isEmpty ? "Surplus prepared food, ready for responsible pickup. Please bring bags or containers if needed." : d.notes)
                .font(HearthFont.body(15))
                .foregroundStyle(HearthTokens.onSurfaceVariant)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(tags(for: d), id: \.self) { t in
                    Text(t)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(HearthTokens.surfaceContainerLow, in: Capsule())
                        .foregroundStyle(HearthTokens.onSurface)
                }
            }
        }
        .padding(16)
        .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous))
        .hearthAmbientShadow()
    }

    private func tags(for d: Donation) -> [String] {
        var t = ["Vegetarian", "Eco-Packaging"]
        if d.foodType == .nonVegetarian { t[0] = "High Protein" }
        return t
    }

    private var donorCard: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(HearthTokens.surfaceContainerLow)
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: "building.columns.fill")
                        .foregroundStyle(HearthTokens.primary)
                }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Hotel Grand")
                        .font(HearthFont.body(16, weight: .bold))
                        .foregroundStyle(HearthTokens.primary)
                    Label("4.8", systemImage: "star.fill")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(HearthTokens.secondary.opacity(0.2), in: Capsule())
                        .foregroundStyle(HearthTokens.secondary)
                }
                Text("Crowned Elite Donor · 242 rescues")
                    .font(.caption)
                    .foregroundStyle(HearthTokens.onSurfaceVariant)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(HearthTokens.onSurfaceVariant.opacity(0.5))
        }
        .padding(16)
        .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func pickupMapSection(_ d: Donation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1, green: 0.9, blue: 0.92), Color(red: 0.85, green: 0.92, blue: 1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 140)
                Image(systemName: "mappin.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(HearthTokens.primary)
            }
            Text("Pickup Location")
                .font(HearthFont.display(17, weight: .bold))
            Text(d.pickupLocation)
                .font(HearthFont.body(15))
                .foregroundStyle(HearthTokens.onSurfaceVariant)
            Button {
            } label: {
                Label("Get Directions", systemImage: "location.fill")
                    .font(HearthFont.body(15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(HearthTokens.surfaceContainerLow, in: Capsule())
                    .foregroundStyle(HearthTokens.onSurface)
            }
        }
        .padding(16)
        .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous))
        .hearthAmbientShadow()
    }

    private var claimBar: some View {
        Button {
            isClaimed = true
        } label: {
            Label(isClaimed ? "Claim Submitted" : "Claim This Donation", systemImage: "plus.circle.fill")
                .font(HearthFont.body(17, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isClaimed ? HearthTokens.onSurfaceVariant : HearthTokens.secondary, in: Capsule())
                .foregroundStyle(.white)
        }
        .disabled(isClaimed)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}
