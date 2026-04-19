//
//  ReceiverProfileViews.swift
//  SavePlate
//

import SwiftUI

struct ReceiverProfileView: View {
    @Environment(DonationStore.self) private var store
    @Environment(AppSession.self) private var session
    @Environment(ReceiverAuthManager.self) private var receiverAuth

    private var badgeTitle: String {
        if session.isNGOReceiver { return "SERVING THE NEEDY" }
        if store.receiverClaimHistory.count >= 3 { return "TOP RECEIVER" }
        return "VERIFIED MEMBER"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    profileHeader
                    descriptionCard

                    VStack(spacing: 12) {
                        NavigationLink {
                            EditReceiverProfileView()
                                .environment(store)
                                .environment(session)
                                .environment(receiverAuth)
                        } label: {
                            Text("Edit Profile")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(HearthTokens.mintTint, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .foregroundStyle(HearthTokens.primary)
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            ReceiverHistoryView()
                                .environment(store)
                        } label: {
                            Label("History", systemImage: "clock.arrow.circlepath")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(HearthTokens.outlineVariant.opacity(0.3), lineWidth: 1)
                                )
                                .foregroundStyle(HearthTokens.onSurface)
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        receiverAuth.logout()
                        session.returnToReceiverOnboarding()
                    } label: {
                        Text("Sign Out")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .foregroundStyle(HearthTokens.primary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .hearthScreenBackground()
            .navigationTitle("Profile")
            .hearthNavBar()
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(HearthTokens.mintTint)
                    .frame(width: 102, height: 102)
                    .overlay {
                        Image(systemName: store.receiverAvatarSymbol)
                            .font(.system(size: 40))
                            .foregroundStyle(HearthTokens.primary)
                    }

                Image(systemName: "checkmark.seal.fill")
                    .font(.title3)
                    .foregroundStyle(HearthTokens.primary)
                    .background(Circle().fill(HearthTokens.surfaceContainerLowest).padding(2))
            }

            Text(store.receiverProfileName)
                .font(HearthFont.display(30, weight: .bold))
                .multilineTextAlignment(.center)

            Text(session.isNGOReceiver ? "NGO Name" : "Name")
                .font(.caption.weight(.semibold))
                .foregroundStyle(HearthTokens.onSurfaceVariant)

            Label(store.receiverCity, systemImage: "mappin.and.ellipse")
                .font(.subheadline)
                .foregroundStyle(HearthTokens.onSurfaceVariant)

            Text(badgeTitle)
                .font(HearthFont.labelCaps(11))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(HearthTokens.mintTint, in: Capsule())
                .foregroundStyle(HearthTokens.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About this receiver")
                .font(.subheadline.weight(.bold))
            Text(store.receiverBio)
                .font(.subheadline)
                .foregroundStyle(HearthTokens.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .hearthAmbientShadow()
    }
}

@MainActor
@Observable
final class EditReceiverProfileViewModel {
    var displayName: String = ""
    var location: String = ""
    var selectedAvatar: String = "person.fill"

    let avatarOptions = ["person.fill", "person.2.fill", "building.2.fill", "hands.sparkles.fill"]

    func load(from store: DonationStore) {
        displayName = store.receiverProfileName
        location = store.receiverCity
        selectedAvatar = store.receiverAvatarSymbol
    }

    var canSave: Bool {
        displayName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
            && !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func save(to store: DonationStore) {
        store.receiverProfileName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        store.receiverCity = location.trimmingCharacters(in: .whitespacesAndNewlines)
        store.receiverAvatarSymbol = selectedAvatar
    }
}

struct EditReceiverProfileView: View {
    @Environment(DonationStore.self) private var store
    @Environment(AppSession.self) private var session
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = EditReceiverProfileViewModel()

    var body: some View {
        @Bindable var vm = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Edit receiver profile")
                    .font(HearthFont.display(28, weight: .bold))

                Text("Keep your receiver details updated so donors can identify and trust your requests.")
                    .font(HearthFont.body(15))
                    .foregroundStyle(HearthTokens.onSurfaceVariant)

                Text(session.isNGOReceiver ? "NGO NAME" : "NAME")
                    .font(HearthFont.labelCaps(11))
                    .foregroundStyle(HearthTokens.onSurfaceVariant)
                TextField(session.isNGOReceiver ? "e.g. Hope Kitchen Foundation" : "e.g. Priya Yadav", text: $vm.displayName)
                    .textInputAutocapitalization(.words)
                    .padding(14)
                    .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                Text("LOCATION")
                    .font(HearthFont.labelCaps(11))
                    .foregroundStyle(HearthTokens.onSurfaceVariant)
                TextField("e.g. Seattle, WA", text: $vm.location)
                    .textInputAutocapitalization(.words)
                    .padding(14)
                    .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                Text("PROFILE PICTURE")
                    .font(HearthFont.labelCaps(11))
                    .foregroundStyle(HearthTokens.onSurfaceVariant)

                HStack(spacing: 10) {
                    ForEach(vm.avatarOptions, id: \.self) { symbol in
                        Button {
                            vm.selectedAvatar = symbol
                        } label: {
                            Image(systemName: symbol)
                                .font(.title3)
                                .foregroundStyle(vm.selectedAvatar == symbol ? HearthTokens.primary : HearthTokens.onSurfaceVariant)
                                .frame(width: 48, height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(vm.selectedAvatar == symbol ? HearthTokens.mintTint : HearthTokens.surfaceContainerLow)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    vm.save(to: store)
                    dismiss()
                } label: {
                    Text("Update Profile")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(HearthTokens.primary, in: Capsule())
                        .foregroundStyle(.white)
                }
                .disabled(!vm.canSave)
                .opacity(vm.canSave ? 1 : 0.45)
                .padding(.top, 8)
            }
            .padding(20)
            .padding(.bottom, 24)
        }
        .hearthScreenBackground()
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .hearthNavBar()
        .onAppear {
            viewModel.load(from: store)
        }
    }
}

struct ReceiverHistoryView: View {
    @Environment(DonationStore.self) private var store

    var body: some View {
        List {
            if store.receiverClaimHistory.isEmpty {
                ContentUnavailableView("No history yet", systemImage: "clock")
            } else {
                ForEach(store.receiverClaimHistory.sorted(by: { $0.claimedAt > $1.claimedAt })) { claim in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(claim.title)
                            .font(.headline)
                        Text(claim.quantityText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        HStack {
                            Text(claim.claimedAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Label("\(claim.pointsUsed) pts", systemImage: "star.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(HearthTokens.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .hearthScreenBackground()
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .hearthNavBar()
    }
}

#Preview {
    ReceiverProfileView()
        .environment(DonationStore())
        .environment(AppSession())
        .environment(ReceiverAuthManager())
}
