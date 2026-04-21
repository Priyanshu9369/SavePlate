//
//  DonorRootTabView.swift
//  SavePlate
//

import SwiftUI

struct DonorRootTabView: View {
    @Environment(DonationStore.self) private var store
    @Environment(AuthManager.self) private var auth
    @State private var tab = 0
    @State private var realtimeVM: RealtimeDonationViewModel?

    var body: some View {
        Group {
            if let realtimeVM {
                TabView(selection: $tab) {
                    DonorHomeView(goToDonate: { tab = 1 }, goToProfile: { tab = 4 })
                        .tabItem { Label("Home", systemImage: "house.fill") }
                        .tag(0)
                        .environment(store)

                    DonorRealtimeDonateView(vm: realtimeVM)
                        .tabItem { Label("Donate", systemImage: "hands.and.sparkles.fill") }
                        .tag(1)

                    DonorImpactDashboardView()
                        .tabItem { Label("Impact", systemImage: "chart.bar.fill") }
                        .tag(2)
                        .environment(store)

                    RealtimeHistoryView(vm: realtimeVM)
                        .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
                        .tag(3)

                    DonorProfileView()
                        .tabItem { Label("Profile", systemImage: "person.fill") }
                        .tag(4)
                        .environment(store)
                }
            } else {
                ProgressView("Preparing real-time session...")
            }
        }
        .tint(HearthColor.forest)
        .hearthTabBar()
        .onAppear {
            guard realtimeVM == nil else { return }
            let user = AppUser(
                id: "donor_\(auth.currentUserIdentifier ?? "default")",
                name: auth.currentUserDisplayName ?? store.kitchenDisplayName,
                role: .donor
            )
            realtimeVM = RealtimeDonationViewModel(currentUser: user)
        }
    }
}
