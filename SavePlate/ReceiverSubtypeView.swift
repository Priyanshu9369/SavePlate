//
//  ReceiverSubtypeView.swift
//  Second screen: choose NGO or Individual (need food path).
//

import SwiftUI

struct ReceiverSubtypeView: View {
    @Environment(AppSession.self) private var session

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header

                Text("How will you rescue food?")
                    .font(HearthFont.display(28, weight: .bold))
                    .foregroundStyle(HearthTokens.onSurface)

                Text("Partners coordinate pickups; individuals browse what’s nearby. Same mission—different tools.")
                    .font(HearthFont.body(16))
                    .foregroundStyle(HearthTokens.onSurfaceVariant)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 16) {
                    subtypeCard(
                        title: "NGO or organization",
                        subtitle: "Institutional dashboard, stock, and rescue alerts.",
                        icon: "building.2.fill",
                        iconTint: HearthTokens.primary,
                        action: { session.chooseReceiverNGO() }
                    )

                    subtypeCard(
                        title: "Individual",
                        subtitle: "Claim surplus for yourself, family, or neighbors.",
                        icon: "person.fill",
                        iconTint: HearthTokens.secondary,
                        action: { session.chooseReceiverIndividual() }
                    )
                }

                Button {
                    session.returnToLanding()
                } label: {
                    Text("Back")
                        .font(HearthFont.body(15, weight: .semibold))
                        .foregroundStyle(HearthTokens.primary)
                }
                .padding(.top, 8)
                .frame(maxWidth: .infinity)
            }
            .padding(24)
            .padding(.bottom, 40)
        }
        .hearthScreenBackground()
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "leaf.fill")
                .foregroundStyle(HearthTokens.primary)
            Text(HearthBrand.name)
                .font(HearthFont.body(17, weight: .bold))
                .foregroundStyle(HearthTokens.primary)
        }
    }

    private func subtypeCard(
        title: String,
        subtitle: String,
        icon: String,
        iconTint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(HearthTokens.surfaceContainerLow)
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(iconTint)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(HearthFont.display(18, weight: .bold))
                        .foregroundStyle(HearthTokens.onSurface)
                        .multilineTextAlignment(.leading)
                    Text(subtitle)
                        .font(HearthFont.body(14))
                        .foregroundStyle(HearthTokens.onSurfaceVariant)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(HearthTokens.onSurfaceVariant.opacity(0.6))
            }
            .padding(20)
            .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous))
            .hearthAmbientShadow()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ReceiverSubtypeView()
        .environment(AppSession())
}
