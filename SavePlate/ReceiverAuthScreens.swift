//
//  ReceiverAuthScreens.swift
//  "I need food" → Sign In / Sign Up (NGO vs Individual), mock auth.
//

import SwiftUI

// MARK: - Navigation

private enum ReceiverAuthRoute: Hashable {
    case signUp
}

// MARK: - Flow root

struct ReceiverAuthFlowView: View {
    @State private var path = NavigationPath()
    @State private var selectedKind: ReceiverAuthKind = .ngo

    var body: some View {
        NavigationStack(path: $path) {
            ReceiverSignInView(path: $path, selectedKind: $selectedKind)
                .navigationDestination(for: ReceiverAuthRoute.self) { route in
                    switch route {
                    case .signUp:
                        ReceiverSignUpView(path: $path, selectedKind: $selectedKind)
                    }
                }
        }
    }
}

// MARK: - Sign In (MVVM)

@MainActor
@Observable
final class ReceiverSignInViewModel {
    var identifier: String = ""
    var password: String = ""
}

struct ReceiverSignInView: View {
    @Binding var path: NavigationPath
    @Binding var selectedKind: ReceiverAuthKind

    @Environment(AppSession.self) private var session
    @Environment(ReceiverAuthManager.self) private var receiverAuth
    @Environment(DonationStore.self) private var store

    @State private var viewModel = ReceiverSignInViewModel()
    @State private var errorMessage: String?
    @State private var showGoogleDemoNotice = false
    @FocusState private var focusedField: SignInField?

    private enum SignInField {
        case identifier, password
    }

    var body: some View {
        @Bindable var vm = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(HearthTokens.primary)
                    Text(HearthBrand.name)
                        .font(HearthFont.body(16, weight: .bold))
                        .foregroundStyle(HearthTokens.primary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Access rescues")
                        .font(HearthFont.display(28, weight: .bold))
                        .foregroundStyle(HearthTokens.onSurface)
                    Text("Sign in with the same account type you used when you registered.")
                        .font(HearthFont.body(15))
                        .foregroundStyle(HearthTokens.onSurfaceVariant)
                }

                Picker("Account type", selection: $selectedKind) {
                    ForEach(ReceiverAuthKind.allCases) { kind in
                        Text(kind.title).tag(kind)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("Account type")

                VStack(alignment: .leading, spacing: 16) {
                    fieldLabel("Email or mobile number")
                    TextField("you@example.com or mobile", text: $vm.identifier)
                        .textContentType(.username)
                        .keyboardType(.default)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .identifier)
                        .padding(14)
                        .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    fieldLabel("Password")
                    SecureField("Your password", text: $vm.password)
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
                    .disabled(!canSubmitSignIn)

                    googleButton

                    VStack(spacing: 12) {
                        Text("New here?")
                            .font(.subheadline)
                            .foregroundStyle(HearthTokens.onSurfaceVariant)
                        Button {
                            errorMessage = nil
                            path.append(ReceiverAuthRoute.signUp)
                        } label: {
                            Text("Create new account")
                                .font(HearthFont.body(16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(HearthTokens.surfaceContainerLow, in: Capsule())
                                .foregroundStyle(HearthTokens.primary)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(20)
                .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous))
                .hearthAmbientShadow()
            }
            .padding(20)
            .padding(.bottom, 24)
        }
        .hearthScreenBackground()
        .navigationTitle("Sign in")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Back") {
                    session.returnToLanding()
                }
                .foregroundStyle(HearthTokens.primary)
            }
        }
        .hearthNavBar()
        .alert("Google Sign-In", isPresented: $showGoogleDemoNotice) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("In production, Google would complete sign-in here. This demo uses email or phone and password.")
        }
    }

    private var canSubmitSignIn: Bool {
        !viewModel.identifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !viewModel.password.isEmpty
    }

    private func signInTapped() {
        errorMessage = nil
        if let err = receiverAuth.login(
            kind: selectedKind,
            identifier: viewModel.identifier,
            password: viewModel.password
        ) {
            errorMessage = err
            return
        }
        receiverAuth.syncToStore(store)
        switch selectedKind {
        case .ngo:
            session.chooseReceiverNGO()
        case .individual:
            session.chooseReceiverIndividual()
        }
    }

    private var googleButton: some View {
        Button {
            showGoogleDemoNotice = true
        } label: {
            HStack {
                Image(systemName: "globe")
                Text("Sign in with Google")
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
        .padding(.top, 4)
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(HearthFont.body(13, weight: .bold))
            .foregroundStyle(HearthTokens.onSurface)
    }
}

// MARK: - Sign Up (MVVM)

@MainActor
@Observable
final class ReceiverSignUpViewModel {
    var displayName: String = ""
    var identifier: String = ""
    var password: String = ""
}

struct ReceiverSignUpView: View {
    @Binding var path: NavigationPath
    @Binding var selectedKind: ReceiverAuthKind

    @Environment(ReceiverAuthManager.self) private var receiverAuth

    @State private var viewModel = ReceiverSignUpViewModel()
    @State private var errorMessage: String?
    @State private var successFlash = false

    var body: some View {
        @Bindable var vm = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Create account")
                    .font(HearthFont.display(26, weight: .bold))
                    .foregroundStyle(HearthTokens.onSurface)
                Text("Choose NGO if you represent an organization, or Individual for personal pickups.")
                    .font(HearthFont.body(15))
                    .foregroundStyle(HearthTokens.onSurfaceVariant)

                Picker("Account type", selection: $selectedKind) {
                    ForEach(ReceiverAuthKind.allCases) { kind in
                        Text(kind.title).tag(kind)
                    }
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: 16) {
                    fieldLabel(selectedKind == .ngo ? "NGO name" : "Your name")
                    TextField(selectedKind == .ngo ? "e.g. Hope Street Kitchen" : "e.g. Priya Sharma", text: $vm.displayName)
                        .textInputAutocapitalization(.words)
                        .padding(14)
                        .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    fieldLabel("Email or mobile number")
                    TextField("you@example.com or mobile", text: $vm.identifier)
                        .textContentType(.username)
                        .keyboardType(.default)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(14)
                        .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    fieldLabel("Password")
                    SecureField("At least 6 characters", text: $vm.password)
                        .textContentType(.newPassword)
                        .padding(14)
                        .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    if successFlash {
                        Text("Account created. Sign in with the same details.")
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
                    .disabled(!canSubmitSignUp)
                    .opacity(canSubmitSignUp ? 1 : 0.45)
                }
                .padding(20)
                .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous))
                .hearthAmbientShadow()
            }
            .padding(20)
        }
        .hearthScreenBackground()
        .navigationTitle("Sign up")
        .navigationBarTitleDisplayMode(.inline)
        .hearthNavBar()
    }

    private var canSubmitSignUp: Bool {
        viewModel.displayName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
            && !viewModel.identifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && viewModel.password.count >= 6
    }

    private func registerTapped() {
        errorMessage = nil
        successFlash = false
        if let err = receiverAuth.register(
            kind: selectedKind,
            displayName: viewModel.displayName,
            identifier: viewModel.identifier,
            password: viewModel.password
        ) {
            errorMessage = err
            return
        }
        successFlash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            if !path.isEmpty {
                path.removeLast()
            }
        }
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(HearthFont.body(13, weight: .bold))
            .foregroundStyle(HearthTokens.onSurface)
    }
}

#Preview("Receiver auth") {
    ReceiverAuthFlowView()
        .environment(AppSession())
        .environment(ReceiverAuthManager())
        .environment(DonationStore())
}
