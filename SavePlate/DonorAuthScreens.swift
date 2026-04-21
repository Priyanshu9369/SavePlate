//
//  DonorAuthScreens.swift
//  Donor flow: Sign In → (Sign Up) → Dashboard (gated by AuthManager).
//

import SwiftUI

// MARK: - Navigation

private enum DonorAuthRoute: Hashable {
    case signUp
}

/// Root container for unauthenticated donors: Sign In with push to Sign Up.
struct DonorAuthFlowView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            DonorSignInView(path: $path)
                .navigationDestination(for: DonorAuthRoute.self) { route in
                    switch route {
                    case .signUp:
                        DonorSignUpView()
                    }
                }
        }
    }
}

// MARK: - Sign In

struct DonorSignInView: View {
    @Binding var path: NavigationPath
    @Environment(AuthManager.self) private var auth
    @Environment(AppSession.self) private var session
    @Environment(DonationStore.self) private var store

    @State private var identifier = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?

    private enum Field {
        case identifier, password
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome back")
                        .font(HearthFont.display(28, weight: .bold))
                        .foregroundStyle(HearthTokens.onSurface)
                    Text("Sign in to list surplus food and track your impact.")
                        .font(HearthFont.body(15))
                        .foregroundStyle(HearthTokens.onSurfaceVariant)
                }

                VStack(alignment: .leading, spacing: 16) {
                    fieldLabel("Email or Phone Number")
                    TextField("you@example.com or +91 9876543210", text: $identifier)
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .focused($focusedField, equals: .identifier)
                        .padding(14)
                        .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    fieldLabel("Password")
                    SecureField("Your password", text: $password)
                        .textContentType(.password)
                        .focused($focusedField, equals: .password)
                        .padding(14)
                        .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Button(action: signInTapped) {
                        Text("Sign In")
                            .font(HearthFont.body(17, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(HearthTokens.primary, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    .disabled(identifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || password.isEmpty)

                    googleSignInButton

                    VStack(spacing: 12) {
                        Text("New to The Conscious Hearth?")
                            .font(.subheadline)
                            .foregroundStyle(HearthTokens.onSurfaceVariant)
                        Button {
                            errorMessage = nil
                            path.append(DonorAuthRoute.signUp)
                        } label: {
                            Text("Sign Up")
                                .font(HearthFont.body(16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(HearthTokens.surfaceContainerLow, in: Capsule())
                                .foregroundStyle(HearthTokens.primary)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(22)
                .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous))
                .hearthAmbientShadow()

                demoHint
            }
            .padding(20)
        }
        .hearthScreenBackground()
        .navigationTitle("Donor sign in")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Back") {
                    session.returnToLanding()
                }
                .foregroundStyle(HearthTokens.primary)
            }
        }
    }

    private var demoHint: some View {
        Text("Demo: create an account with email/phone, or try Google sign-in.")
            .font(.caption)
            .foregroundStyle(HearthTokens.onSurfaceVariant)
    }

    private var googleSignInButton: some View {
        Button {
            errorMessage = nil
            auth.loginWithGoogle()
            store.accountEmail = auth.currentUserIdentifier ?? ""
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "globe")
                    .font(.subheadline.weight(.bold))
                Text("Sign in with Google")
                    .font(HearthFont.body(16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white, in: Capsule())
            .overlay(Capsule().stroke(HearthTokens.outlineVariant.opacity(0.4), lineWidth: 1))
            .foregroundStyle(HearthTokens.onSurface)
        }
        .buttonStyle(.plain)
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(HearthFont.body(13, weight: .semibold))
            .foregroundStyle(HearthTokens.onSurface)
    }

    private func signInTapped() {
        errorMessage = nil
        guard auth.isValidIdentifier(identifier) else {
            errorMessage = "Enter a valid email or phone number."
            return
        }
        if let err = auth.login(identifier: identifier, password: password) {
            errorMessage = err
            return
        }
        store.accountEmail = auth.currentUserIdentifier ?? identifier.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Sign Up

struct DonorSignUpView: View {
    @Environment(AuthManager.self) private var auth
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var identifier = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var successBanner = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Create donor account")
                        .font(HearthFont.display(26, weight: .bold))
                        .foregroundStyle(HearthTokens.onSurface)
                    Text("Join as a donor to share surplus with your community.")
                        .font(HearthFont.body(15))
                        .foregroundStyle(HearthTokens.onSurfaceVariant)
                }

                VStack(alignment: .leading, spacing: 16) {
                    fieldLabel("Name")
                    TextField("Your full name", text: $name)
                        .textContentType(.name)
                        .padding(14)
                        .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    fieldLabel("Email or Phone Number")
                    TextField("you@example.com or +91 9876543210", text: $identifier)
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .padding(14)
                        .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    fieldLabel("Password")
                    SecureField("At least 6 characters", text: $password)
                        .padding(14)
                        .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    if successBanner {
                        Text("Account created. Sign in with your new credentials.")
                            .font(.caption)
                            .foregroundStyle(HearthTokens.primary)
                    }

                    Button(action: registerTapped) {
                        Text("Create account")
                            .font(HearthFont.body(17, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(HearthTokens.secondary, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    .disabled(!canSubmit)
                }
                .padding(22)
                .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous))
                .hearthAmbientShadow()
            }
            .padding(20)
        }
        .hearthScreenBackground()
        .navigationTitle("Sign up")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !identifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && password.count >= 6
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(HearthFont.body(13, weight: .semibold))
            .foregroundStyle(HearthTokens.onSurface)
    }

    private func registerTapped() {
        errorMessage = nil
        successBanner = false
        guard auth.isValidIdentifier(identifier) else {
            errorMessage = "Enter a valid email or phone number."
            return
        }
        if let err = auth.register(name: name, identifier: identifier, password: password) {
            errorMessage = err
            return
        }
        successBanner = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            dismiss()
        }
    }
}

#Preview("Auth flow") {
    DonorAuthFlowView()
        .environment(AuthManager())
}
