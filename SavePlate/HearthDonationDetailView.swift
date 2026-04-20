//
//  HearthDonationDetailView.swift
//  SavePlate
//

import SwiftUI

struct HearthDonationDetailView: View {
    @Environment(DonationStore.self) private var store
    let donation: Donation
    /// When `nil`, donor-only actions are hidden (e.g. receiver browsing).
    var onEdit: (() -> Void)?

    init(donation: Donation, onEdit: (() -> Void)? = nil) {
        self.donation = donation
        self.onEdit = onEdit
    }

    private var live: Donation? { store.donations.first { $0.id == donation.id } }

    var body: some View {
        Group {
            if let d = live {
                List {
                    Section("Overview") {
                        LabeledContent("Food", value: d.foodName)
                        LabeledContent("Quantity") {
                            Text(quantityLabel(for: d))
                        }
                        LabeledContent("Type", value: d.foodType.label)
                        LabeledContent("Impact", value: "\(d.estimatedMealsSaved()) meals (est.)")
                    }
                    Section("Pickup") {
                        LabeledContent("Location", value: d.pickupLocation)
                        LabeledContent("Expires") {
                            Text(d.expiry.formatted(date: .abbreviated, time: .shortened))
                        }
                    }
                    if !d.notes.isEmpty {
                        Section("Notes") {
                            Text(d.notes)
                        }
                    }
                    transparencySection(for: d)
                    if onEdit != nil {
                        Section {
                            Button("Edit details") { onEdit?() }
                            if d.isActive && !d.isCancelled {
                                Button("Mark as cancelled", role: .destructive) {
                                    store.cancel(d)
                                }
                            }
                            Button("Delete permanently", role: .destructive) {
                                store.delete(d)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            } else {
                ContentUnavailableView("Removed", systemImage: "trash", description: Text("This listing is no longer available."))
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .hearthScreenBackground()
        .hearthNavBar()
    }

    private func quantityLabel(for d: Donation) -> String {
        let fmt = d.unit == .plates ? "%.0f" : "%.1f"
        return String(format: fmt, d.quantity) + " " + d.unit.abbreviation
    }

    @ViewBuilder
    private func transparencySection(for d: Donation) -> some View {
        let proofs = store.receiverProofs(forDonationId: d.id)
        let reviews = store.receiverReviews(forDonationId: d.id)
        if !proofs.isEmpty || !reviews.isEmpty {
            Section("Receiver transparency") {
                if !proofs.isEmpty {
                    Text("Distribution proof")
                        .font(.subheadline.weight(.bold))
                    ForEach(proofs) { proof in
                        VStack(alignment: .leading, spacing: 6) {
                            Label(proof.caption, systemImage: proof.mediaKind == "video" ? "film" : "photo")
                            Text(proof.attachmentStub)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(proof.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                if !reviews.isEmpty {
                    Text("Community feedback")
                        .font(.subheadline.weight(.bold))
                    ForEach(reviews) { r in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(r.authorName)
                                .font(.subheadline.weight(.semibold))
                            Text(r.reviewText)
                            if !r.mediaNote.isEmpty {
                                Text(r.mediaNote)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Text(r.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}
