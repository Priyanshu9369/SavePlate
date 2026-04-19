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
                        DonorSignUpView(path: $path)
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

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?

    private enum Field {
        case email, password
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
                    fieldLabel("Email")
                    TextField("you@example.com", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .focused($focusedField, equals: .email)
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
                    .disabled(email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || password.isEmpty)

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
        Text("Demo: use Sign Up to create an account, then sign in with the same email and password.")
            .font(.caption)
            .foregroundStyle(HearthTokens.onSurfaceVariant)
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(HearthFont.body(13, weight: .semibold))
            .foregroundStyle(HearthTokens.onSurface)
    }

    private func signInTapped() {
        errorMessage = nil
        if let err = auth.login(email: email, password: password) {
            errorMessage = err
            return
        }
        store.accountEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Sign Up

struct DonorSignUpView: View {
    @Binding var path: NavigationPath
    @Environment(AuthManager.self) private var auth

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
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
                    fieldLabel("Email")
                    TextField("you@example.com", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .padding(14)
                        .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    fieldLabel("Password")
                    SecureField("At least 6 characters", text: $password)
                        .padding(14)
                        .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    fieldLabel("Confirm password")
                    SecureField("Repeat password", text: $confirmPassword)
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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    if !path.isEmpty { path.removeLast() }
                } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                        .foregroundStyle(HearthTokens.primary)
                }
            }
        }
    }

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && password.count >= 6
            && password == confirmPassword
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(HearthFont.body(13, weight: .semibold))
            .foregroundStyle(HearthTokens.onSurface)
    }

    private func registerTapped() {
        errorMessage = nil
        successBanner = false
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        if let err = auth.register(email: email, password: password) {
            errorMessage = err
            return
        }
        successBanner = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if !path.isEmpty {
                path.removeLast()
            }
        }
    }
}

#Preview("Auth flow") {
    DonorAuthFlowView()
        .environment(AuthManager())
}
