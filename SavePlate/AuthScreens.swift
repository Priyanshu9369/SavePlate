//
//  AuthScreens.swift
//  SavePlate
//

import SwiftUI

struct AuthSignInView: View {
    @Environment(DonationStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    /// 0 = NGO, 1 = Individual
    @State private var accountKind = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Label(HearthBrand.name, systemImage: "leaf.fill")
                            .font(HearthFont.body(15, weight: .bold))
                            .foregroundStyle(HearthTokens.primary)
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(HearthTokens.onSurfaceVariant)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sign In to Your Hearth")
                            .font(HearthFont.display(28, weight: .bold))
                            .foregroundStyle(HearthTokens.onSurface)
                        Text("Rejoin the movement of curating and sharing surplus resources with those who need it most.")
                            .font(HearthFont.body(15))
                            .foregroundStyle(HearthTokens.onSurfaceVariant)
                    }

                    VStack(alignment: .leading, spacing: 18) {
                        roleSegmented

                        fieldLabel("Email Address")
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(HearthTokens.onSurfaceVariant.opacity(0.7))
                            TextField(accountKind == 0 ? "name@organization.org" : "name@example.com", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                        }
                        .padding(14)
                        .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                        HStack(alignment: .firstTextBaseline) {
                            fieldLabel("Password")
                            Spacer()
                            Button("Forgot?") {}
                                .font(HearthFont.body(13, weight: .semibold))
                                .foregroundStyle(HearthTokens.secondary)
                        }

                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(HearthTokens.onSurfaceVariant.opacity(0.7))
                            SecureField("Password", text: $password)
                        }
                        .padding(14)
                        .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                        Button(action: signIn) {
                            Text("Sign In")
                                .font(HearthFont.body(17, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(HearthTokens.primary, in: Capsule())
                                .foregroundStyle(.white)
                        }
                        .disabled(email.isEmpty || password.isEmpty)
                        .opacity(email.isEmpty || password.isEmpty ? 0.45 : 1)
                        .padding(.top, 4)

                        HStack {
                            Rectangle()
                                .fill(HearthTokens.onSurfaceVariant.opacity(0.12))
                                .frame(height: 1)
                            Text("OR CONTINUE WITH")
                                .font(HearthFont.labelCaps(9))
                                .foregroundStyle(HearthTokens.onSurfaceVariant)
                            Rectangle()
                                .fill(HearthTokens.onSurfaceVariant.opacity(0.12))
                                .frame(height: 1)
                        }
                        .padding(.vertical, 8)

                        Button {
                        } label: {
                            HStack {
                                Image(systemName: "globe")
                                Text("Google Sign In")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(HearthTokens.surfaceContainerLowest, in: Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(HearthTokens.outlineVariant.opacity(0.35), lineWidth: 1)
                            )
                            .foregroundStyle(HearthTokens.onSurface)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(22)
                    .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous))
                    .hearthAmbientShadow()

                    HStack(spacing: 4) {
                        Text("New here?")
                            .foregroundStyle(HearthTokens.onSurfaceVariant)
                        Button("Create a new account") {}
                            .fontWeight(.semibold)
                            .foregroundStyle(HearthTokens.primary)
                    }
                    .font(HearthFont.body(14))
                    .frame(maxWidth: .infinity)
                }
                .padding(20)
                .padding(.bottom, 32)
            }
            .hearthScreenBackground()
            .navigationBarHidden(true)
        }
    }

    private var roleSegmented: some View {
        HStack(spacing: 0) {
            roleButton(title: "NGO", icon: "building.2.fill", selected: accountKind == 0) {
                accountKind = 0
            }
            roleButton(title: "Individual", icon: "person.fill", selected: accountKind == 1) {
                accountKind = 1
            }
        }
        .padding(4)
        .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func roleButton(title: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(selected ? HearthTokens.surfaceContainerLowest : Color.clear, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .foregroundStyle(selected ? HearthTokens.primary : HearthTokens.onSurface)
        }
        .buttonStyle(.plain)
    }

    private func fieldLabel(_ t: String) -> some View {
        Text(t)
            .font(HearthFont.body(13, weight: .bold))
            .foregroundStyle(HearthTokens.onSurface)
    }

    private func signIn() {
        store.accountEmail = email
        dismiss()
    }
}

struct NGORegistrationView: View {
    @Environment(DonationStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var orgName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var humanWelfare = true
    @State private var missionText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 8) {
                        Image(systemName: "leaf.fill")
                            .foregroundStyle(HearthTokens.primary)
                        Text(HearthBrand.name)
                            .font(HearthFont.body(15, weight: .bold))
                            .foregroundStyle(HearthTokens.primary)
                    }

                    Text("Join as NGO.")
                        .font(HearthFont.display(30, weight: .bold))
                        .foregroundStyle(HearthTokens.primary)

                    Text("Connect with local resource providers and amplify your mission's impact. Our hearth is open to those who serve.")
                        .font(HearthFont.body(15))
                        .foregroundStyle(HearthTokens.onSurfaceVariant)

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous)
                            .fill(HearthGradient.pulseGreen)
                        VStack(alignment: .leading, spacing: 10) {
                            Image(systemName: "hands.and.sparkles.fill")
                                .foregroundStyle(.white)
                            Text("12.4k")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("MEALS RESCUED TODAY")
                                .font(HearthFont.labelCaps(11))
                                .foregroundStyle(.white.opacity(0.9))
                            Text("Your registration helps us reach zero-waste milestones across 40+ communities.")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.88))
                        }
                        .padding(20)
                    }
                    .frame(minHeight: 160)

                    VStack(alignment: .leading, spacing: 16) {
                        sectionLabel("ORGANIZATION IDENTITY")
                        inputField("Organization Name", text: $orgName, prompt: "Harbor Street Kitchen")
                        inputField("Email Address", text: $email, prompt: "contact@ngo.org")
                        SecureField("Password", text: $password)
                            .padding(14)
                            .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                        sectionLabel("MISSION FOCUS")
                        HStack(spacing: 0) {
                            missionChip(title: "Human Welfare", icon: "person.3.fill", selected: humanWelfare) {
                                humanWelfare = true
                            }
                            missionChip(title: "Animal Welfare", icon: "pawprint.fill", selected: !humanWelfare) {
                                humanWelfare = false
                            }
                        }
                        .padding(4)
                        .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                        sectionLabel("YOUR CREATIVITY & OUTREACH")
                        TextField("Describe your unique impact or community outreach strategy...", text: $missionText, axis: .vertical)
                            .lineLimit(4...8)
                            .padding(14)
                            .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                        Button(action: complete) {
                            HStack {
                                Text("Complete Registration")
                                    .fontWeight(.bold)
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(HearthTokens.secondary, in: Capsule())
                            .foregroundStyle(.white)
                        }
                        .disabled(orgName.count < 2 || !email.contains("@"))
                        .opacity(orgName.count < 2 || !email.contains("@") ? 0.45 : 1)

                        HStack(spacing: 4) {
                            Text("Already have an account?")
                            Button("Sign In") { dismiss() }
                                .fontWeight(.semibold)
                                .foregroundStyle(HearthTokens.secondary)
                        }
                        .font(HearthFont.body(14))
                        .frame(maxWidth: .infinity)
                    }
                    .padding(20)
                    .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous))
                    .hearthAmbientShadow()
                }
                .padding(20)
            }
            .hearthScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(HearthTokens.primary)
                    }
                }
            }
            .hearthNavBar()
        }
    }

    private func sectionLabel(_ t: String) -> some View {
        Text(t)
            .font(HearthFont.labelCaps(11))
            .foregroundStyle(HearthTokens.onSurfaceVariant)
    }

    private func inputField(_ title: String, text: Binding<String>, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(HearthFont.body(12, weight: .semibold))
            TextField(prompt, text: text)
                .padding(14)
                .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func missionChip(title: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(selected ? HearthTokens.mintTint : Color.clear, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(selected ? HearthTokens.primary.opacity(0.45) : Color.clear, lineWidth: selected ? 1.5 : 0)
            )
            .foregroundStyle(selected ? HearthTokens.primary : HearthTokens.onSurface)
        }
        .buttonStyle(.plain)
    }

    private func complete() {
        store.receiverProfileName = orgName.trimmingCharacters(in: .whitespacesAndNewlines)
        store.accountEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        dismiss()
    }
}
