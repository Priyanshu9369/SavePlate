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
}
