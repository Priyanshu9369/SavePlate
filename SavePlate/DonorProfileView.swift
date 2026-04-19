//
//  DonorProfileView.swift
//  SavePlate
//

import SwiftUI

struct DonorProfileView: View {
    @Environment(DonationStore.self) private var store
    @Environment(AppSession.self) private var session
    @Environment(AuthManager.self) private var auth

    private var homeAreaBinding: Binding<String> {
        Binding(
            get: { store.homeArea },
            set: { store.homeArea = $0 }
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    yourSpaceSection

                    profileHeaderSection

                    donorTypeRow

                    VStack(spacing: 12) {
                        NavigationLink {
                            EditDonorProfileView()
                                .environment(store)
                        } label: {
                            Text("Edit donor profile")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(HearthColor.mint, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .foregroundStyle(HearthColor.forest)
                        }
                        .buttonStyle(.plain)

                        Button {
                            auth.logout()
                        } label: {
                            Text("Sign out")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .foregroundStyle(HearthTokens.primary)
                        }
                    }

                    if let email = auth.currentUserEmail {
                        Text("Signed in as \(email)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Button(role: .destructive) {
                        auth.logout()
                        session.returnToLanding()
                    } label: {
                        Text("Switch journey (Donor / Receiver)")
                            .font(.subheadline.weight(.semibold))
                    }
                    .padding(.top, 12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .scrollContentBackground(.hidden)
            .hearthScreenBackground()
            .navigationTitle("Profile")
            .hearthNavBar()
        }
    }

    // MARK: - Sections

    private var yourSpaceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your space")
                .font(.headline)
            Text("Home or service area for matching with nearby NGOs.")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("Neighborhood, city, or area", text: homeAreaBinding)
                .textFieldStyle(.roundedBorder)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var profileHeaderSection: some View {
        VStack(spacing: 12) {
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
            .padding(.top, 4)

            Text(store.kitchenDisplayName)
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)

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
        }
        .frame(maxWidth: .infinity)
    }

    private var donorTypeRow: some View {
        HStack {
            Text("Donor type")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(HearthTokens.onSurfaceVariant)
            Spacer()
            Label(store.donorKitchenCategory.label, systemImage: store.donorKitchenCategory == .restaurant ? "fork.knife" : "house.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(HearthTokens.primary)
        }
        .padding(14)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    DonorProfileView()
        .environment(DonationStore())
        .environment(AppSession())
        .environment(AuthManager())
}
