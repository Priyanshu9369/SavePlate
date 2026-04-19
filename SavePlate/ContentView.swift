//
//  ContentView.swift
//  SavePlate
//

import SwiftUI

struct ContentView: View {
    @State private var store = DonationStore()
    @State private var session = AppSession()
    @State private var authManager = AuthManager()
    @State private var receiverAuth = ReceiverAuthManager()

    var body: some View {
        Group {
            switch session.path {
            case .landing:
                LandingView()
                    .environment(session)
            case .donor:
                Group {
                    if authManager.isAuthenticated {
                        DonorRootTabView()
                            .environment(store)
                            .environment(session)
                            .environment(authManager)
                    } else {
                        DonorAuthFlowView()
                            .environment(store)
                            .environment(session)
                            .environment(authManager)
                    }
                }
            case .receiverOnboarding:
                ReceiverAuthFlowView()
                    .environment(store)
                    .environment(session)
                    .environment(receiverAuth)
            case .receiverNGO, .receiverIndividual:
                Group {
                    if receiverAuth.isAuthenticated {
                        ReceiverRootTabView()
                            .environment(store)
                            .environment(session)
                            .environment(receiverAuth)
                    } else {
                        ReceiverAuthFlowView()
                            .environment(store)
                            .environment(session)
                            .environment(receiverAuth)
                    }
                }
            }
        }
        .onChange(of: session.path) { _, newPath in
            switch newPath {
            case .donor:
                store.userRole = .donor
            case .receiverNGO, .receiverIndividual, .receiverOnboarding:
                store.userRole = .receiver
            case .landing:
                break
            }
        }
        .onAppear {
            switch session.path {
            case .donor:
                store.userRole = .donor
            case .receiverNGO, .receiverIndividual, .receiverOnboarding:
                store.userRole = .receiver
            case .landing:
                break
            }
        }
    }
}

#Preview {
    ContentView()
}
