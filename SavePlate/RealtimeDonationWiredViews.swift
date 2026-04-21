//
//  RealtimeDonationWiredViews.swift
//  SavePlate
//

import SwiftUI

struct DonorRealtimeDonateView: View {
    @Bindable var vm: RealtimeDonationViewModel

    @State private var foodDetails = ""
    @State private var quantity = ""
    @State private var latitude = ""
    @State private var longitude = ""

    /// In production, fetch these from your users table by role.
    private let defaultReceiverIds = ["receiver_ngo_default", "receiver_individual_default"]

    var body: some View {
        NavigationStack {
            List {
                Section("Create donation") {
                    TextField("Food details", text: $foodDetails)
                    TextField("Quantity (e.g. 20 meal boxes)", text: $quantity)
                    TextField("Latitude", text: $latitude)
                        .keyboardType(.decimalPad)
                    TextField("Longitude", text: $longitude)
                        .keyboardType(.decimalPad)

                    Button("Post Donation (Real-time)") {
                        guard
                            let lat = Double(latitude),
                            let lng = Double(longitude)
                        else {
                            vm.errorMessage = "Enter valid latitude and longitude."
                            return
                        }
                        vm.createDonation(
                            foodDetails: foodDetails.trimmingCharacters(in: .whitespacesAndNewlines),
                            quantity: quantity.trimmingCharacters(in: .whitespacesAndNewlines),
                            latitude: lat,
                            longitude: lng,
                            receiverIds: defaultReceiverIds
                        )
                        foodDetails = ""
                        quantity = ""
                        latitude = ""
                        longitude = ""
                    }
                    .disabled(foodDetails.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || quantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Section("Live available feed") {
                    if vm.availableFeed.isEmpty {
                        Text("No active donations.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(vm.availableFeed) { d in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(d.foodDetails).font(.headline)
                                Text("\(d.quantity) · \(d.latitude), \(d.longitude)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(d.status.rawValue.capitalized)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(.green)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .navigationTitle("Donate Food")
            .onAppear { vm.start() }
        }
    }
}

