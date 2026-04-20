//
//  ReceiverControlPanelViews.swift
//  Control panel hub: riders (NGO), stock, distribution proof, community reviews.
//

import PhotosUI
import SwiftUI

// MARK: - Hub

struct ControlPanelView: View {
    @Environment(AppSession.self) private var session

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Manage operations, transparency, and community trust from one place.")
                    .font(.subheadline)
                    .foregroundStyle(HearthTokens.onSurfaceVariant)

                if session.isNGOReceiver {
                    panelCard(
                        title: "Rider management",
                        subtitle: "Add drivers and update contact details.",
                        symbol: "bicycle",
                        destination: RiderManagementView()
                    )
                }

                panelCard(
                    title: "Food stock tracker",
                    subtitle: "Full · Medium · Low · Empty — shown on Home.",
                    symbol: "archivebox.fill",
                    destination: StockTrackerView()
                )

                panelCard(
                    title: "Distribution proof",
                    subtitle: "Photo or video proof linked to donations when possible.",
                    symbol: "camera.fill",
                    destination: DistributionProofView()
                )

                panelCard(
                    title: "Reviews & feedback",
                    subtitle: "Quotes and optional media from people you served.",
                    symbol: "heart.text.square.fill",
                    destination: ReviewsView()
                )
            }
            .padding(20)
        }
        .hearthScreenBackground()
        .navigationTitle("Control Panel")
        .navigationBarTitleDisplayMode(.inline)
        .hearthNavBar()
    }

    private func panelCard<Destination: View>(
        title: String,
        subtitle: String,
        symbol: String,
        destination: Destination
    ) -> some View {
        NavigationLink {
            destination
        } label: {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(HearthTokens.mintTint.opacity(0.55))
                        .frame(width: 48, height: 48)
                    Image(systemName: symbol)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(HearthTokens.primary)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(HearthFont.body(17, weight: .bold))
                        .foregroundStyle(HearthTokens.onSurface)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(HearthTokens.onSurfaceVariant)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(HearthTokens.onSurfaceVariant.opacity(0.7))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .hearthAmbientShadow()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Riders (NGO)

struct RiderManagementView: View {
    @Environment(DonationStore.self) private var store
    @Environment(AppSession.self) private var session

    @State private var draft = RiderDraft()
    @State private var editing: ReceiverRider?
    @State private var showEditor = false

    var body: some View {
        Group {
            if session.isNGOReceiver {
                listContent
            } else {
                ContentUnavailableView(
                    "NGO only",
                    systemImage: "building.columns",
                    description: Text("Rider lists are available for organization accounts. Individuals can still track stock, proof, and reviews.")
                )
            }
        }
        .navigationTitle("Riders")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if session.isNGOReceiver {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editing = nil
                        draft = RiderDraft()
                        showEditor = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(HearthTokens.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            NavigationStack {
                RiderEditorSheet(
                    draft: $draft,
                    title: editing == nil ? "Add rider" : "Edit rider",
                    onSave: {
                        let rider = ReceiverRider(
                            id: editing?.id ?? UUID(),
                            name: draft.name.trimmingCharacters(in: .whitespacesAndNewlines),
                            phone: draft.phone.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        store.upsertReceiverRider(rider)
                        showEditor = false
                    },
                    onCancel: { showEditor = false }
                )
            }
        }
        .hearthScreenBackground()
        .hearthNavBar()
    }

    private var listContent: some View {
        Group {
            if store.receiverRiders.isEmpty {
                ContentUnavailableView(
                    "No riders yet",
                    systemImage: "person.badge.plus",
                    description: Text("Tap + to add a name and phone number.")
                )
            } else {
                List {
                    ForEach(store.receiverRiders) { rider in
                        Button {
                            editing = rider
                            draft = RiderDraft(name: rider.name, phone: rider.phone)
                            showEditor = true
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(rider.name)
                                    .font(.body.weight(.semibold))
                                Text(rider.phone)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for i in indexSet {
                            store.deleteReceiverRider(id: store.receiverRiders[i].id)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
}

private struct RiderDraft {
    var name = ""
    var phone = ""
}

private struct RiderEditorSheet: View {
    @Binding var draft: RiderDraft
    let title: String
    let onSave: () -> Void
    let onCancel: () -> Void

    private var canSave: Bool {
        !draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !draft.phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section("Rider") {
                TextField("Name", text: $draft.name)
                    .textContentType(.name)
                TextField("Phone", text: $draft.phone)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: onCancel)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { onSave() }
                    .disabled(!canSave)
            }
        }
    }
}

// MARK: - Stock

struct StockTrackerView: View {
    @Environment(DonationStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Your pantry level appears in **The Hearth Feed** on Home so your team sees status at a glance.")
                    .font(.subheadline)
                    .foregroundStyle(HearthTokens.onSurfaceVariant)

                VStack(spacing: 12) {
                    ForEach(ReceiverFoodStockLevel.allCases) { level in
                        stockOption(level)
                    }
                }
            }
            .padding(20)
        }
        .hearthScreenBackground()
        .navigationTitle("Food stock")
        .navigationBarTitleDisplayMode(.inline)
        .hearthNavBar()
    }

    private func stockOption(_ level: ReceiverFoodStockLevel) -> some View {
        let selected = store.receiverFoodStockLevel == level
        return Button {
            store.receiverFoodStockLevel = level
        } label: {
            HStack(spacing: 14) {
                Circle()
                    .fill(stockIndicatorColor(level.statusToken))
                    .frame(width: 14, height: 14)
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(HearthTokens.onSurface)
                    Text(stockDetail(level))
                        .font(.caption)
                        .foregroundStyle(HearthTokens.onSurfaceVariant)
                }
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(HearthTokens.primary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                HearthTokens.surfaceContainerLowest,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(selected ? HearthTokens.primary.opacity(0.45) : HearthTokens.outlineVariant.opacity(0.15), lineWidth: selected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func stockDetail(_ level: ReceiverFoodStockLevel) -> String {
        switch level {
        case .full: "Well stocked — great position for the week."
        case .medium: "Comfortable levels — watch busy distribution days."
        case .low: "Running low — plan pickups or ration portions."
        case .empty: "Critical — prioritize incoming rescues."
        }
    }
}

// MARK: - Distribution proof

struct DistributionProofView: View {
    @Environment(DonationStore.self) private var store

    @State private var caption = ""
    @State private var mediaKind = "photo"
    @State private var selectedDonationId: UUID?
    @State private var pickedItem: PhotosPickerItem?
    @State private var attachmentStub = ""

    private let mediaChoices = [("photo", "Photo"), ("video", "Video")]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Proof is stored locally for this demo and can be linked to a listing so donors see transparency on the donation detail screen.")
                    .font(.subheadline)
                    .foregroundStyle(HearthTokens.onSurfaceVariant)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Link to donation (optional)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(HearthTokens.onSurfaceVariant)
                    Picker("Donation", selection: $selectedDonationId) {
                        Text("General / not linked").tag(Optional<UUID>.none)
                        ForEach(store.donations) { d in
                            Text("\(d.foodName) — \(d.pickupLocation)").tag(Optional(d.id))
                        }
                    }
                    .pickerStyle(.menu)
                }

                Picker("Media type", selection: $mediaKind) {
                    ForEach(mediaChoices, id: \.0) { pair in
                        Text(pair.1).tag(pair.0)
                    }
                }
                .pickerStyle(.segmented)

                PhotosPicker(
                    selection: $pickedItem,
                    matching: mediaKind == "video" ? .videos : .images
                ) {
                    Label(
                        mediaKind == "video" ? "Choose video" : "Choose photo",
                        systemImage: mediaKind == "video" ? "film" : "photo"
                    )
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(HearthTokens.surfaceContainerLow, in: Capsule())
                }
                .onChange(of: pickedItem) { _, item in
                    guard let item else { return }
                    Task {
                        let stub = await Self.stubLabel(for: item, mediaKind: mediaKind)
                        await MainActor.run { attachmentStub = stub }
                    }
                }

                Button {
                    attachmentStub = mediaKind == "video"
                        ? "demo_clip_\(UUID().uuidString.prefix(6)).mov"
                        : "demo_photo_\(UUID().uuidString.prefix(6)).jpg"
                } label: {
                    Text("Use mock file (no library)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(HearthTokens.secondary)
                }

                if !attachmentStub.isEmpty {
                    Text("Attachment: \(attachmentStub)")
                        .font(.caption)
                        .foregroundStyle(HearthTokens.onSurfaceVariant)
                }

                TextField("Caption (what was distributed?)", text: $caption, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(.roundedBorder)

                Button {
                    let stub = attachmentStub.isEmpty
                        ? (mediaKind == "video" ? "unspecified_video.mov" : "unspecified_photo.jpg")
                        : attachmentStub
                    store.addReceiverDistributionProof(
                        donationId: selectedDonationId,
                        caption: caption.isEmpty ? "Distribution logged" : caption,
                        mediaKind: mediaKind,
                        attachmentStub: stub
                    )
                    caption = ""
                    pickedItem = nil
                    attachmentStub = ""
                } label: {
                    Text("Save proof")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(HearthTokens.primary, in: Capsule())
                        .foregroundStyle(.white)
                }

                if !store.receiverDistributionProofs.isEmpty {
                    Text("Recent")
                        .font(HearthFont.display(16, weight: .bold))
                    ForEach(store.receiverDistributionProofs.prefix(8)) { proof in
                        proofRow(proof)
                    }
                }
            }
            .padding(20)
        }
        .hearthScreenBackground()
        .navigationTitle("Distribution proof")
        .navigationBarTitleDisplayMode(.inline)
        .hearthNavBar()
    }

    private func proofRow(_ proof: ReceiverDistributionProof) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: proof.mediaKind == "video" ? "film.fill" : "photo.fill")
                    .foregroundStyle(HearthTokens.primary)
                Text(proof.caption)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(proof.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text(proof.attachmentStub)
                .font(.caption)
                .foregroundStyle(.secondary)
            if let id = proof.donationId, let d = store.donations.first(where: { $0.id == id }) {
                Text("Linked: \(d.foodName)")
                    .font(.caption2)
                    .foregroundStyle(HearthTokens.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private static func stubLabel(for item: PhotosPickerItem, mediaKind: String) async -> String {
        if let id = item.itemIdentifier { return id }
        let ext = mediaKind == "video" ? "mov" : "jpg"
        return "library_pick_\(UUID().uuidString.prefix(8)).\(ext)"
    }
}

// MARK: - Reviews

struct ReviewsView: View {
    @Environment(DonationStore.self) private var store

    @State private var authorName = ""
    @State private var reviewText = ""
    @State private var mediaNote = ""
    @State private var selectedDonationId: UUID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Capture kind words from recipients. Optional media note describes a photo or video you have on file.")
                    .font(.subheadline)
                    .foregroundStyle(HearthTokens.onSurfaceVariant)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Related donation (optional)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(HearthTokens.onSurfaceVariant)
                    Picker("Donation", selection: $selectedDonationId) {
                        Text("Not linked").tag(Optional<UUID>.none)
                        ForEach(store.donations) { d in
                            Text("\(d.foodName)").tag(Optional(d.id))
                        }
                    }
                    .pickerStyle(.menu)
                }

                TextField("Recipient or community member name", text: $authorName)
                    .textFieldStyle(.roundedBorder)
                TextField("Review text", text: $reviewText, axis: .vertical)
                    .lineLimit(4...8)
                    .textFieldStyle(.roundedBorder)
                TextField("Optional photo/video note", text: $mediaNote)
                    .textFieldStyle(.roundedBorder)

                Button {
                    let name = authorName.trimmingCharacters(in: .whitespacesAndNewlines)
                    let text = reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !name.isEmpty, !text.isEmpty else { return }
                    store.addReceiverCommunityReview(
                        donationId: selectedDonationId,
                        authorName: name,
                        reviewText: text,
                        mediaNote: mediaNote.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                    authorName = ""
                    reviewText = ""
                    mediaNote = ""
                } label: {
                    Text("Save review")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(HearthTokens.secondary, in: Capsule())
                        .foregroundStyle(.white)
                }
                .disabled(
                    authorName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )

                if !store.receiverCommunityReviews.isEmpty {
                    Text("Recent")
                        .font(HearthFont.display(16, weight: .bold))
                    ForEach(store.receiverCommunityReviews.prefix(8)) { r in
                        reviewRow(r)
                    }
                }
            }
            .padding(20)
        }
        .hearthScreenBackground()
        .navigationTitle("Reviews")
        .navigationBarTitleDisplayMode(.inline)
        .hearthNavBar()
    }

    private func reviewRow(_ r: ReceiverCommunityReview) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(r.authorName)
                    .font(.subheadline.weight(.bold))
                Spacer()
                Text(r.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text(r.reviewText)
                .font(.subheadline)
            if !r.mediaNote.isEmpty {
                Label(r.mediaNote, systemImage: "paperclip")
                    .font(.caption)
                    .foregroundStyle(HearthTokens.onSurfaceVariant)
            }
            if let id = r.donationId, let d = store.donations.first(where: { $0.id == id }) {
                Text("Linked: \(d.foodName)")
                    .font(.caption2)
                    .foregroundStyle(HearthTokens.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Shared helpers

func stockIndicatorColor(_ statusToken: String) -> Color {
    switch statusToken {
    case "green": Color.green
    case "yellow": Color.yellow
    case "orange": Color.orange
    case "red": Color.red
    default: HearthTokens.onSurfaceVariant
    }
}
