//
//  ReceiverVolunteerViews.swift
//  Local volunteer management for receiver users.
//

import PhotosUI
import SwiftUI

struct AddVolunteerView: View {
    @Environment(DonationStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var localTag = "Nearby helper"
    @State private var status: ReceiverVolunteerStatus = .active
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section("Profile") {
                HStack(spacing: 14) {
                    volunteerAvatar(imageData: selectedImageData, status: status, size: 64)
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Upload photo", systemImage: "photo.badge.plus")
                    }
                }
                TextField("Name", text: $name)
                    .textContentType(.name)
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }

            Section("Helper status") {
                Picker("Status", selection: $status) {
                    ForEach(ReceiverVolunteerStatus.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                TextField("Local tag (e.g. Ward 3)", text: $localTag)
            }
        }
        .navigationTitle("Add Volunteer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let volunteer = ReceiverVolunteer(
                        id: UUID(),
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                        imageData: selectedImageData,
                        status: status,
                        localTag: localTag.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                    store.upsertReceiverVolunteer(volunteer)
                    dismiss()
                }
                .disabled(!canSave)
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            Task {
                selectedImageData = try? await newItem.loadTransferable(type: Data.self)
            }
        }
    }
}

struct VolunteerListView: View {
    @Environment(DonationStore.self) private var store

    var body: some View {
        Group {
            if store.receiverVolunteersSorted.isEmpty {
                ContentUnavailableView(
                    "No volunteers yet",
                    systemImage: "person.2.slash",
                    description: Text("Tap + on Home to add local helpers.")
                )
            } else {
                List {
                    Section("Active volunteers: \(store.activeReceiverVolunteersCount)") {
                        ForEach(store.receiverVolunteersSorted) { volunteer in
                            volunteerRow(volunteer)
                        }
                        .onDelete { indexSet in
                            for idx in indexSet {
                                let volunteer = store.receiverVolunteersSorted[idx]
                                store.deleteReceiverVolunteer(id: volunteer.id)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .hearthScreenBackground()
        .navigationTitle("Volunteers")
        .navigationBarTitleDisplayMode(.inline)
        .hearthNavBar()
    }

    private func volunteerRow(_ volunteer: ReceiverVolunteer) -> some View {
        HStack(spacing: 12) {
            volunteerAvatar(imageData: volunteer.imageData, status: volunteer.status, size: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(volunteer.name)
                    .font(.body.weight(.semibold))
                Text(volunteer.email)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !volunteer.localTag.isEmpty {
                    Label(volunteer.localTag, systemImage: "location.fill")
                        .font(.caption2)
                        .foregroundStyle(HearthTokens.onSurfaceVariant)
                }
            }
            Spacer()
            Picker(
                "Status",
                selection: Binding(
                    get: { volunteer.status },
                    set: { store.updateReceiverVolunteerStatus(id: volunteer.id, status: $0) }
                )
            ) {
                Text("Active").tag(ReceiverVolunteerStatus.active)
                Text("Offline").tag(ReceiverVolunteerStatus.offline)
            }
            .pickerStyle(.menu)
        }
        .padding(.vertical, 4)
    }
}

@ViewBuilder
func volunteerAvatar(imageData: Data?, status: ReceiverVolunteerStatus, size: CGFloat) -> some View {
    ZStack(alignment: .bottomTrailing) {
        Group {
            if let data = imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.16)
                    .foregroundStyle(HearthTokens.primary)
                    .background(HearthTokens.surfaceContainerLow)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())

        Circle()
            .fill(volunteerStatusColor(status))
            .frame(width: max(10, size * 0.22), height: max(10, size * 0.22))
            .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
    }
}

func volunteerStatusColor(_ status: ReceiverVolunteerStatus) -> Color {
    switch status {
    case .active:
        .green
    case .offline:
        .gray
    }
}
