//
//  DonorHistoryView.swift
//  SavePlate
//

import SwiftUI

struct DonorHistoryView: View {
    @Environment(DonationStore.self) private var store
    @State private var showMap = false
    @State private var editingDetail: Donation?

    private var historyRows: [Donation] {
        store.donations.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    cumulativeCard

                    HStack {
                        Text("Recent Contributions")
                            .font(.headline)
                        Spacer()
                        Text("Showing last 3 months")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 4)

                    LazyVStack(spacing: 12) {
                        ForEach(historyRows) { d in
                            NavigationLink(value: d) {
                                historyRow(d)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button {
                    } label: {
                        Text("Load Older History")
                            .font(.subheadline.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray5), in: Capsule())
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 28)
            }
            .scrollContentBackground(.hidden)
            .hearthScreenBackground()
            .navigationTitle("Donation History")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Donation.self) { d in
                HearthDonationDetailView(donation: d) {
                    editingDetail = d
                }
            }
            .sheet(item: $editingDetail) { d in
                NavigationStack {
                    DonateFoodFlowEditView(donation: d)
                        .environment(store)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showMap = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundStyle(HearthColor.forest)
                    }
                }
            }
            .sheet(isPresented: $showMap) {
                DonationsMapView()
                    .environment(store)
            }
            .hearthNavBar()
        }
    }

    private var cumulativeCard: some View {
        VStack(spacing: 12) {
            Text("YOUR CUMULATIVE IMPACT")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(HearthColor.earthMuted)

            Text(String(format: "%.1f kg", store.totalKgDonated))
                .font(.system(size: 36, weight: .bold, design: .rounded))

            Text("Impact Tier: \(store.impactTierTitle)")
                .font(.caption.weight(.bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(HearthColor.mint, in: Capsule())
                .foregroundStyle(HearthColor.forest)

            Text("\(store.donationsCountThisCalendarMonth) donations this month")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }

    private func historyRow(_ d: Donation) -> some View {
        let pet = d.notes.localizedCaseInsensitiveContains("pet food")
        return HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(HearthColor.mint.opacity(0.6))
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(HearthColor.forest.opacity(0.5))
                }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(pet ? "ANIMAL/PET FOOD" : "HUMAN FOOD")
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(pet ? Color.orange : HearthColor.leaf, in: Capsule())
                        .foregroundStyle(.white)
                    Spacer()
                    Text(d.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Text(d.foodName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(detailSubtitle(d))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Label(statusText(d), systemImage: statusIcon(d))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(statusColor(d, pet: pet))
            }
        }
        .padding(12)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    private func detailSubtitle(_ d: Donation) -> String {
        let fmt = d.unit == .plates ? "%.0f" : "%.1f"
        let q = String(format: fmt, d.quantity)
        return "\(q) \(d.unit.abbreviation) · \(d.pickupLocation)"
    }

    private func statusText(_ d: Donation) -> String {
        if d.isCancelled { return "Cancelled" }
        if d.isActive { return "Listed for pickup" }
        return d.notes.localizedCaseInsensitiveContains("pet") ? "Delivered to Local Shelter" : "Successfully Handovered"
    }

    private func statusIcon(_ d: Donation) -> String {
        if d.isCancelled { return "xmark.circle.fill" }
        if d.isActive { return "clock.fill" }
        return d.notes.localizedCaseInsensitiveContains("pet") ? "pawprint.fill" : "checkmark.circle.fill"
    }

    private func statusColor(_ d: Donation, pet: Bool) -> Color {
        if d.isCancelled { return .secondary }
        if d.isActive { return HearthColor.forest }
        return pet ? Color(red: 0.47, green: 0.33, blue: 0.28) : HearthColor.leaf
    }
}
