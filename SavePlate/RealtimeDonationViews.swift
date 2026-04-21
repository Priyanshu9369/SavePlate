//
//  RealtimeDonationViews.swift
//  SavePlate
//

import SwiftUI

struct RealtimeFeedView: View {
    @Bindable var vm: RealtimeDonationViewModel

    var body: some View {
        List {
            if vm.availableFeed.isEmpty {
                ContentUnavailableView("No available donations", systemImage: "tray")
            } else {
                ForEach(vm.availableFeed) { donation in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(donation.foodDetails).font(.headline)
                        Text(donation.quantity).font(.subheadline).foregroundStyle(.secondary)
                        Text("By \(donation.donorName)").font(.caption)
                        Text("Location: \(donation.latitude), \(donation.longitude)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Button("Accept") {
                            vm.acceptDonation(donation)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(donation.status != .available || vm.currentUser.role == .donor)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle("Live Feed")
        .overlay(alignment: .bottom) {
            if let msg = vm.bannerMessage {
                Text(msg)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.bottom, 10)
            }
        }
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .onAppear { vm.start() }
    }
}

struct RealtimeHistoryView: View {
    @Bindable var vm: RealtimeDonationViewModel

    var body: some View {
        List {
            if vm.currentUser.role == .donor {
                ForEach(vm.donorHistory) { donation in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(donation.foodDetails).font(.headline)
                        Text("Status: \(donation.status.rawValue.capitalized)")
                        if let acceptedByName = donation.acceptedByName {
                            Text("Accepted by: \(acceptedByName)")
                                .font(.subheadline)
                        }
                    }
                    .padding(.vertical, 4)
                }
            } else {
                ForEach(vm.receiverHistory) { donation in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(donation.foodDetails).font(.headline)
                        Text("Donor: \(donation.donorName)")
                        Text("Status: \(donation.status.rawValue.capitalized)")
                        if donation.status == .accepted {
                            Button("Mark Completed") { vm.completeDonation(donation) }
                                .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("History")
        .onAppear { vm.start() }
    }
}

struct RealtimeNotificationsView: View {
    @Bindable var vm: RealtimeDonationViewModel

    var body: some View {
        List(vm.notifications) { n in
            VStack(alignment: .leading, spacing: 4) {
                Text(n.title).font(.headline)
                Text(n.body).font(.subheadline)
                Text(n.createdAt, style: .relative).font(.caption).foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Notifications")
        .onAppear { vm.start() }
    }
}

