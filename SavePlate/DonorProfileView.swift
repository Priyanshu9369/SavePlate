//
//  DonorProfileView.swift
//  SavePlate
//

import SwiftUI

struct DonorProfileView: View {
    @Environment(DonationStore.self) private var store
    @Environment(AppSession.self) private var session

    @State private var showCreate = false
    @State private var showSignIn = false
    @State private var homeAreaEdit = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(HearthColor.mint)
                            .frame(width: 96, height: 96)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(HearthColor.forest)
                            }
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title3)
                            .foregroundStyle(HearthColor.earth)
                            .background(Circle().fill(Color.white).padding(2))
                    }
                    .padding(.top, 8)

                    Text(store.kitchenDisplayName)
                        .font(.title2.weight(.bold))

                    HStack(spacing: 8) {
                        Text("TOP DONOR 2024")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(HearthColor.forest, in: Capsule())
                            .foregroundStyle(.white)
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.orange)
                            Text("4.9 Community Trust")
                                .font(.caption.weight(.semibold))
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your space")
                            .font(.headline)
                        TextField("Home area (for matching)", text: $homeAreaEdit)
                            .textFieldStyle(.roundedBorder)
                            .onAppear { homeAreaEdit = store.homeArea }
                            .onChange(of: homeAreaEdit) { _, v in
                                store.homeArea = v
                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    VStack(spacing: 12) {
                        Button {
                            showCreate = true
                        } label: {
                            Text("Create donor profile")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(HearthColor.mint, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .foregroundStyle(HearthColor.forest)
                        }
                        Button {
                            showSignIn = true
                        } label: {
                            Text("Sign in")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(HearthColor.forest, lineWidth: 1.5))
                                .foregroundStyle(HearthColor.forest)
                        }
                    }

                    Button(role: .destructive) {
                        session.returnToLanding()
                    } label: {
                        Text("Switch journey (Donor / Receiver)")
                            .font(.subheadline.weight(.semibold))
                    }
                    .padding(.top, 12)

                    if !store.accountEmail.isEmpty {
                        Text("Signed in as \(store.accountEmail)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .scrollContentBackground(.hidden)
            .hearthScreenBackground()
            .navigationTitle("Profile")
            .sheet(isPresented: $showCreate) {
                AuthCreateDonorProfileView()
                    .environment(store)
            }
            .sheet(isPresented: $showSignIn) {
                AuthSignInView()
                    .environment(store)
            }
            .hearthNavBar()
        }
    }
}
