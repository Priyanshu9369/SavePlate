//
//  DonorRootTabView.swift
//  SavePlate
//

import SwiftUI

struct DonorRootTabView: View {
    @Environment(DonationStore.self) private var store
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            DonorHomeView(goToDonate: { tab = 1 }, goToProfile: { tab = 4 })
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)
                .environment(store)

            DonorDonateHubView()
                .tabItem { Label("Donate", systemImage: "hands.and.sparkles.fill") }
                .tag(1)
                .environment(store)

            DonorImpactDashboardView()
                .tabItem { Label("Impact", systemImage: "chart.bar.fill") }
                .tag(2)
                .environment(store)

            DonorHistoryView()
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
                .tag(3)
                .environment(store)

            DonorProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(4)
                .environment(store)
        }
        .tint(HearthColor.forest)
        .hearthTabBar()
    }
}
