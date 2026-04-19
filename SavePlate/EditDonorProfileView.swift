//
//  EditDonorProfileView.swift
//  SavePlate — donor profile editor (MVVM, no auth fields).
//

import SwiftUI

// MARK: - ViewModel

@MainActor
@Observable
final class EditDonorProfileViewModel {
    var donorName: String = ""
    var homeArea: String = ""
    var category: DonorKitchenCategory = .restaurant

    func load(from store: DonationStore) {
        donorName = store.kitchenDisplayName
        homeArea = store.homeArea
        category = store.donorKitchenCategory
    }

    func apply(to store: DonationStore) {
        let name = donorName.trimmingCharacters(in: .whitespacesAndNewlines)
        store.kitchenDisplayName = name
        store.homeArea = homeArea.trimmingCharacters(in: .whitespacesAndNewlines)
        store.donorKitchenCategory = category
    }

    var canSave: Bool {
        donorName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }
}

// MARK: - View

struct EditDonorProfileView: View {
    @Environment(DonationStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = EditDonorProfileViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text(HearthBrand.tagline)
                    .font(HearthFont.labelCaps(11))
                    .foregroundStyle(HearthColor.earthMuted)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Keep your")
                        .font(HearthFont.display(28, weight: .bold))
                        .foregroundStyle(HearthTokens.onSurface)
                    Text("circle updated.")
                        .font(HearthFont.display(28, weight: .bold))
                        .foregroundStyle(HearthTokens.primary)
                }

                Text("NGOs use this to understand who you are and where you operate. Sign-in email is managed separately.")
                    .font(HearthFont.body(15))
                    .foregroundStyle(HearthTokens.onSurfaceVariant)

                fieldCaps("DONOR CATEGORY")
                donorCategoryPicker

                fieldCaps("NAME OF DONOR")
                TextField("e.g. Hearthside Bistro", text: $viewModel.donorName)
                    .padding(14)
                    .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(HearthTokens.outlineVariant.opacity(0.35)))

                fieldCaps("YOUR SPACE")
                TextField("Neighborhood, city, or area for matching", text: $viewModel.homeArea)
                    .padding(14)
                    .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(HearthTokens.outlineVariant.opacity(0.35)))

                Text("We match surplus listings and NGO needs using this area when possible.")
                    .font(.caption)
                    .foregroundStyle(HearthTokens.onSurfaceVariant)

                Button(action: saveTapped) {
                    HStack {
                        Text("Update Profile")
                            .fontWeight(.bold)
                        Image(systemName: "checkmark")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(HearthTokens.primary, in: Capsule())
                    .foregroundStyle(.white)
                }
                .disabled(!viewModel.canSave)
                .opacity(viewModel.canSave ? 1 : 0.45)
                .padding(.top, 8)
            }
            .padding(20)
            .padding(.bottom, 24)
        }
        .hearthScreenBackground()
        .navigationTitle("Edit Donor Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                        .foregroundStyle(HearthTokens.primary)
                }
            }
        }
        .hearthNavBar()
        .onAppear {
            viewModel.load(from: store)
        }
    }

    private var donorCategoryPicker: some View {
        HStack(spacing: 0) {
            categoryChip(.restaurant, icon: "fork.knife")
            categoryChip(.homeKitchen, icon: "house.fill")
        }
        .padding(4)
        .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func categoryChip(_ cat: DonorKitchenCategory, icon: String) -> some View {
        Button {
            viewModel.category = cat
        } label: {
            HStack {
                Image(systemName: icon)
                Text(cat.label)
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(viewModel.category == cat ? HearthTokens.surfaceContainerLowest : Color.clear, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .foregroundStyle(viewModel.category == cat ? HearthTokens.primary : HearthTokens.onSurface)
            .padding(2)
        }
        .buttonStyle(.plain)
    }

    private func fieldCaps(_ title: String) -> some View {
        Text(title)
            .font(HearthFont.labelCaps(11))
            .foregroundStyle(HearthTokens.onSurfaceVariant)
    }

    private func saveTapped() {
        viewModel.apply(to: store)
        dismiss()
    }
}

#Preview("Edit donor profile") {
    NavigationStack {
        EditDonorProfileView()
            .environment(DonationStore())
    }
}
