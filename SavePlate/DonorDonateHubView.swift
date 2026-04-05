//
//  DonorDonateHubView.swift
//  SavePlate
//

import SwiftUI

struct DonorDonateHubView: View {
    @Environment(DonationStore.self) private var store
    @State private var showPostFlow = false
    @State private var editing: Donation?

    private var rows: [Donation] {
        store.donations.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        NavigationStack {
            Group {
                if rows.isEmpty {
                    ContentUnavailableView(
                        "List surplus food",
                        systemImage: "hand.raised.fill",
                        description: Text("Post what you can share—someone nearby may need it tonight.")
                    )
                } else {
                    List {
                        ForEach(rows) { d in
                            NavigationLink(value: d) {
                                DonateHubRow(donation: d)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    store.delete(d)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                if d.isActive && !d.isCancelled {
                                    Button {
                                        store.cancel(d)
                                    } label: {
                                        Label("Cancel", systemImage: "xmark.circle")
                                    }
                                    .tint(.orange)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Donate Food")
            .navigationDestination(for: Donation.self) { d in
                HearthDonationDetailView(donation: d) {
                    editing = d
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showPostFlow = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(HearthColor.forest)
                    }
                }
            }
            .sheet(isPresented: $showPostFlow) {
                NavigationStack {
                    DonateFoodFlowView()
                        .environment(store)
                }
            }
            .sheet(item: $editing) { d in
                NavigationStack {
                    DonateFoodFlowEditView(donation: d)
                        .environment(store)
                }
            }
            .hearthScreenBackground()
            .hearthNavBar()
        }
    }
}

private struct DonateHubRow: View {
    let donation: Donation

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(HearthColor.mint)
                .frame(width: 52, height: 52)
                .overlay {
                    Image(systemName: donation.foodType.symbolName)
                        .foregroundStyle(HearthColor.forest)
                }
            VStack(alignment: .leading, spacing: 4) {
                Text(donation.foodName)
                    .font(.headline)
                Text(donation.pickupLocation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

/// Simplified editor reusing flow layout for edits (single screen).
struct DonateFoodFlowEditView: View {
    @Environment(DonationStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    private let donationId: UUID
    @State private var foodName: String
    @State private var quantity: Double
    @State private var unit: QuantityUnit
    @State private var pickupLocation: String
    @State private var expiry: Date
    @State private var notes: String

    init(donation: Donation) {
        donationId = donation.id
        _foodName = State(initialValue: donation.foodName)
        _quantity = State(initialValue: donation.quantity)
        _unit = State(initialValue: donation.unit)
        _pickupLocation = State(initialValue: donation.pickupLocation)
        _expiry = State(initialValue: donation.expiry)
        _notes = State(initialValue: donation.notes)
    }

    var body: some View {
        Form {
            Section("Food") {
                TextField("Name", text: $foodName)
                Stepper("\(quantityLabel)", value: $quantity, in: 0.5...500, step: unit == .plates ? 1 : 0.5)
                Picker("Unit", selection: $unit) {
                    ForEach(QuantityUnit.allCases) { u in
                        Text(u.label).tag(u)
                    }
                }
            }
            Section("Pickup") {
                TextField("Location", text: $pickupLocation, axis: .vertical)
                    .lineLimit(2...4)
                DatePicker("Expiry", selection: $expiry, in: Date()...)
            }
            Section("Notes") {
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(2...5)
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Edit listing")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .fontWeight(.bold)
                    .foregroundStyle(HearthColor.forest)
            }
        }
        .hearthScreenBackground()
    }

    private var quantityLabel: String {
        let fmt = unit == .plates ? "%.0f" : "%.1f"
        return String(format: fmt, quantity) + " " + unit.abbreviation
    }

    private func save() {
        guard var d = store.donations.first(where: { $0.id == donationId }) else {
            dismiss()
            return
        }
        d.foodName = foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        d.quantity = quantity
        d.unit = unit
        d.pickupLocation = pickupLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        d.expiry = expiry
        d.notes = notes
        store.update(d)
        dismiss()
    }
}
