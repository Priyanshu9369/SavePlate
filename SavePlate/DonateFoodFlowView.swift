//
//  DonateFoodFlowView.swift
//  SavePlate
//

import PhotosUI
import SwiftUI

struct DonateFoodFlowView: View {
    @Environment(DonationStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var step = 1
    @State private var pickedPhoto: PhotosPickerItem?

    @State private var foodName = ""
    @State private var quantity: Double = 5
    @State private var unit: QuantityUnit = .plates
    @State private var whenMade = "Just now"
    @State private var isHumanFood = true
    @State private var storageNotes = ""
    @State private var pickupLocation = ""
    @State private var expiry = Date().addingTimeInterval(4 * 3600)

    private let whenOptions = ["Just now", "1 hour ago", "Today AM", "Custom"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                progressHeader

                if step == 1 {
                    stepOne
                } else if step == 2 {
                    stepTwo
                } else {
                    stepReview
                }

                footerButtons
            }
            .padding(20)
            .padding(.bottom, 32)
        }
        .background(HearthColor.canvas.ignoresSafeArea())
        .navigationTitle("Donate Food")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Close") { dismiss() }
                    .foregroundStyle(HearthColor.forest)
            }
        }
    }

    private var progressHeader: some View {
        HStack(spacing: 6) {
            ForEach(1...3, id: \.self) { i in
                Capsule()
                    .fill(i <= step ? HearthColor.forest : Color(.systemGray5))
                    .frame(height: 4)
            }
        }
        .padding(.bottom, 8)
    }

    private var stepOne: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("ADD PHOTO OF FOOD")
            PhotosPicker(selection: $pickedPhoto, matching: .images) {
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(HearthColor.mint)
                            .frame(width: 64, height: 64)
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .foregroundStyle(HearthColor.forest)
                    }
                    Text("Tap to capture or upload")
                        .font(.subheadline.weight(.semibold))
                    Text("Clear photos help speed up approval.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                        .foregroundStyle(Color.gray.opacity(0.4))
                )
            }
            .buttonStyle(.plain)

            fieldLabel("WHAT IS THE FOOD?")
            TextField("e.g. Artisan Sourdough Bread", text: $foodName)
                .padding(14)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.08)))

            fieldLabel("QUANTITY")
            HStack(spacing: 10) {
                TextField("e.g. 10", value: $quantity, format: .number)
                    .keyboardType(.decimalPad)
                    .padding(14)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.08)))
                Menu {
                    ForEach(QuantityUnit.allCases) { u in
                        Button(u.label) { unit = u }
                    }
                } label: {
                    Text("UNIT")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }

            fieldLabel("WHEN WAS IT MADE?")
            FlowChips(options: whenOptions, selection: $whenMade)

            fieldLabel("FOOD CATEGORY")
            HStack(spacing: 0) {
                categorySegment(title: "Human", icon: "person.fill", selected: isHumanFood) {
                    isHumanFood = true
                }
                categorySegment(title: "Animal/Pet", icon: "pawprint.fill", selected: !isHumanFood) {
                    isHumanFood = false
                }
            }
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            fieldLabel("STORAGE INSTRUCTIONS")
            TextField("Chilled, room temp, reheating…", text: $storageNotes, axis: .vertical)
                .lineLimit(2...4)
                .padding(14)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.08)))
        }
    }

    private func categorySegment(title: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(selected ? Color.white : Color.clear)
            .foregroundStyle(selected ? HearthColor.forest : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(4)
        }
        .buttonStyle(.plain)
    }

    private var stepTwo: some View {
        VStack(alignment: .leading, spacing: 18) {
            fieldLabel("PICKUP LOCATION")
            TextField("Address or landmark", text: $pickupLocation, axis: .vertical)
                .lineLimit(2...4)
                .padding(14)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.08)))

            fieldLabel("BEST BEFORE / EXPIRY")
            DatePicker("", selection: $expiry, in: Date()...)
                .labelsHidden()
                .datePickerStyle(.graphical)
                .padding(8)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var stepReview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Review")
                .font(.title3.weight(.bold))
            Group {
                labeled("Food", foodName)
                labeled("Quantity", quantityLine)
                labeled("Category", isHumanFood ? "Human food" : "Animal / pet food")
                labeled("Pickup", pickupLocation.isEmpty ? "—" : pickupLocation)
                labeled("Expires", expiry.formatted(date: .abbreviated, time: .shortened))
            }
            .font(.subheadline)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func labeled(_ k: String, _ v: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(k.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            Text(v)
        }
    }

    private var quantityLine: String {
        let fmt = unit == .plates ? "%.0f" : "%.1f"
        return String(format: fmt, quantity) + " " + unit.abbreviation
    }

    @ViewBuilder
    private var footerButtons: some View {
        if step < 3 {
            Button {
                withAnimation { step += 1 }
            } label: {
                Text("Continue")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(HearthColor.forest, in: Capsule())
                    .foregroundStyle(.white)
            }
            .disabled(!canAdvance)
            .opacity(canAdvance ? 1 : 0.45)
        } else {
            Button(action: postDonation) {
                HStack {
                    Text("Post Donation")
                        .fontWeight(.bold)
                    Image(systemName: "paperplane.fill")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(HearthColor.terracotta, in: Capsule())
                .foregroundStyle(.white)
            }
            .disabled(!canPost)
            .opacity(canPost ? 1 : 0.45)

            Text("By posting, you agree to our freshness standards.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }

    private var canAdvance: Bool {
        switch step {
        case 1: return !foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && quantity > 0
        case 2: return !pickupLocation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        default: return true
        }
    }

    private var canPost: Bool { canAdvance && step == 3 }

    private func postDonation() {
        var notes = "[Prep: \(whenMade)]"
        if !storageNotes.isEmpty { notes += " · \(storageNotes)" }
        if !isHumanFood { notes += " · [Pet food]" }

        let type: FoodType = isHumanFood ? .vegetarian : .packaged

        let d = Donation(
            id: UUID(),
            foodName: foodName.trimmingCharacters(in: .whitespacesAndNewlines),
            quantity: quantity,
            unit: unit,
            foodType: type,
            pickupLocation: pickupLocation.trimmingCharacters(in: .whitespacesAndNewlines),
            latitude: nil,
            longitude: nil,
            expiry: expiry,
            notes: notes,
            createdAt: Date(),
            isCancelled: false
        )
        store.add(d)
        dismiss()
    }

    private func fieldLabel(_ t: String) -> some View {
        Text(t)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.42))
    }

    private func sectionTitle(_ t: String) -> some View {
        Text(t)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.42))
    }
}

private struct FlowChips: View {
    let options: [String]
    @Binding var selection: String

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(options, id: \.self) { opt in
                Button {
                    selection = opt
                } label: {
                    HStack {
                        if opt == "Custom" {
                            Image(systemName: "calendar")
                        }
                        Text(opt)
                            .font(.subheadline.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selection == opt ? HearthColor.forest : Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .foregroundStyle(selection == opt ? Color.white : Color.primary)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.black.opacity(0.08), lineWidth: selection == opt ? 0 : 1)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
