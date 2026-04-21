//
//  DonorProfileView.swift
//  SavePlate
//

import SwiftUI

struct DonorProfileView: View {
    @Environment(DonationStore.self) private var store
    @Environment(AuthManager.self) private var auth

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
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
                    }

                    yourSpaceSummaryCard

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

                    if let identifier = auth.currentUserIdentifier {
                        Text("Signed in as \(identifier)")
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
            .hearthNavBar()
        }
    }

    // MARK: - Sections

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

    /// Read-only summary — editing happens in `EditDonorProfileView` only.
    private var yourSpaceSummaryCard: some View {
        let area = store.homeArea.trimmingCharacters(in: .whitespacesAndNewlines)
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(HearthTokens.primary)
                    .frame(width: 40, height: 40)
                    .background(HearthTokens.mintTint, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your space")
                        .font(.headline)
                    Text("Service area for NGO matching")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }

            if area.isEmpty {
                Text("No area saved yet. Tap Edit donor profile above to add where you usually share surplus.")
                    .font(.subheadline)
                    .foregroundStyle(HearthTokens.onSurfaceVariant)
            } else {
                Text(area)
                    .font(.body.weight(.medium))
                    .foregroundStyle(HearthTokens.onSurface)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(HearthTokens.outlineVariant.opacity(0.25), lineWidth: 1)
        )
        .hearthAmbientShadow()
    }
}

#Preview {
    DonorProfileView()
        .environment(DonationStore())
        .environment(AuthManager())
}
