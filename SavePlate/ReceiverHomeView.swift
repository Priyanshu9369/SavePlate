//
//  ReceiverHomeView.swift
//  SavePlate
//

import SwiftUI

struct ReceiverHomeView: View {
    @Environment(DonationStore.self) private var store
    @Environment(AppSession.self) private var session

    @State private var showMap = false

    private var available: [Donation] {
        store.donations.filter(\.isActive).sorted { $0.expiry < $1.expiry }
    }

    var body: some View {
        NavigationStack {
            Group {
                if available.isEmpty {
                    ContentUnavailableView(
                        "No rescues listed yet",
                        systemImage: "basket.fill",
                        description: Text("Check back soon—donors post surplus as it becomes available.")
                    )
                } else {
                    List {
                        ForEach(available) { d in
                            NavigationLink(value: d) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(d.foodName)
                                        .font(.headline)
                                    Text(d.pickupLocation)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("Expires \(d.expiry.formatted(date: .omitted, time: .shortened))")
                                        .font(.caption2)
                                        .foregroundStyle(HearthColor.terracotta)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Local rescues")
            .navigationDestination(for: Donation.self) { d in
                HearthDonationDetailView(donation: d, onEdit: nil)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") {
                        session.returnToLanding()
                    }
                    .foregroundStyle(HearthColor.forest)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showMap = true
                    } label: {
                        Image(systemName: "map.fill")
                            .foregroundStyle(HearthColor.forest)
                    }
                }
            }
            .sheet(isPresented: $showMap) {
                DonationsMapView()
                    .environment(store)
            }
            .hearthScreenBackground()
            .hearthNavBar()
        }
    }
}
