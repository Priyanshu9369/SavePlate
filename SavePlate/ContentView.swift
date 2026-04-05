//
//  ContentView.swift
//  SavePlate
//

import SwiftUI

struct ContentView: View {
    @State private var store = DonationStore()
    @State private var session = AppSession()

    var body: some View {
        Group {
            switch session.path {
            case .landing:
                LandingView()
                    .environment(session)
            case .donor:
                DonorRootTabView()
                    .environment(store)
                    .environment(session)
            case .receiver:
                ReceiverHomeView()
                    .environment(store)
                    .environment(session)
            }
        }
        .onChange(of: session.path) { _, newPath in
            switch newPath {
            case .donor: store.userRole = .donor
            case .receiver: store.userRole = .receiver
            case .landing: break
            }
        }
        .onAppear {
            if session.path == .donor { store.userRole = .donor }
            if session.path == .receiver { store.userRole = .receiver }
        }
    }
}

#Preview {
    ContentView()
}
