//
//  AuthScreens.swift
//  SavePlate
//

import SwiftUI

struct AuthCreateDonorProfileView: View {
    @Environment(DonationStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var category: DonorKitchenCategory = .restaurant
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text(HearthBrand.tagline)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(HearthColor.earthMuted)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Join the")
                            .font(.system(size: 32, weight: .bold))
                        Text("Resource Circle.")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(HearthColor.forestHeader)
                    }

                    Text("Turn surplus into sustenance. Your kitchen is the heart of a healthier community.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    fieldCaps("DONOR CATEGORY")
                    HStack(spacing: 0) {
                        categoryChip(.restaurant, icon: "fork.knife")
                        categoryChip(.homeKitchen, icon: "house.fill")
                    }
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    fieldCaps("NAME OF DONOR")
                    TextField("e.g. Hearthside Bistro", text: $name)
                        .padding(14)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.08)))

                    fieldCaps("EMAIL ADDRESS")
                    TextField("contact@hearthside.com", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(14)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.08)))

                    fieldCaps("PASSWORD")
                    HStack {
                        Group {
                            if showPassword {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                        }
                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(14)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.08)))

                    Text("Must be at least 8 characters including a symbol and a number.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Button(action: save) {
                        HStack {
                            Text("Create Account")
                                .fontWeight(.bold)
                            Image(systemName: "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(HearthColor.forest, in: Capsule())
                        .foregroundStyle(.white)
                    }
                    .disabled(!canSave)
                    .opacity(canSave ? 1 : 0.45)
                    .padding(.top, 8)

                    Text("By creating an account, you agree to our Community Guidelines and Food Safety Standards.")
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
                .padding(20)
            }
            .hearthScreenBackground()
            .navigationTitle("Create Donor Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                            .foregroundStyle(HearthColor.forest)
                    }
                }
            }
            .hearthNavBar()
        }
    }

    private var canSave: Bool {
        name.count >= 2 && email.contains("@") && password.count >= 8
    }

    private func save() {
        store.kitchenDisplayName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        store.accountEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        store.donorKitchenCategory = category
        dismiss()
    }

    private func fieldCaps(_ t: String) -> some View {
        Text(t)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(Color(red: 0.38, green: 0.38, blue: 0.4))
    }

    private func categoryChip(_ cat: DonorKitchenCategory, icon: String) -> some View {
        Button {
            category = cat
        } label: {
            HStack {
                Image(systemName: icon)
                Text(cat.label)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(category == cat ? Color.white : Color.clear)
            .foregroundStyle(category == cat ? HearthColor.forest : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(4)
        }
        .buttonStyle(.plain)
    }
}

struct AuthSignInView: View {
    @Environment(DonationStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Sign In to Your Hearth")
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)
                    Text("Continue your journey in nourishing communities.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Email Address")
                            .font(.caption.weight(.bold))
                        TextField("name@example.com", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .padding(14)
                            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                        Text("Password")
                            .font(.caption.weight(.bold))
                        SecureField("••••••••", text: $password)
                            .padding(14)
                            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                        HStack {
                            Spacer()
                            Button("Forgot Password?") {}
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(HearthColor.forest)
                        }

                        Button(action: signIn) {
                            Text("Sign In")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(HearthColor.forest, in: Capsule())
                                .foregroundStyle(.white)
                        }
                        .disabled(email.isEmpty || password.isEmpty)
                        .opacity(email.isEmpty || password.isEmpty ? 0.45 : 1)
                    }
                    .padding(20)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.06), radius: 12, y: 4)

                    HStack {
                        Rectangle().fill(Color.gray.opacity(0.25)).frame(height: 1)
                        Text("OR CONTINUE WITH")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                        Rectangle().fill(Color.gray.opacity(0.25)).frame(height: 1)
                    }
                    .padding(.vertical, 8)

                    HStack(spacing: 12) {
                        socialButton(title: "Google", systemImage: "globe", dark: false)
                        socialButton(title: "Apple", systemImage: "apple.logo", dark: true)
                    }
                }
                .padding(20)
            }
            .hearthScreenBackground()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(HearthColor.forest)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(HearthBrand.name)
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                        .foregroundStyle(HearthColor.forestHeader)
                }
            }
            .hearthNavBar()
        }
    }

    private func socialButton(title: String, systemImage: String, dark: Bool) -> some View {
        Button {
        } label: {
            HStack {
                Image(systemName: systemImage)
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(dark ? Color.black : Color(.systemGray5), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .foregroundStyle(dark ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
    }

    private func signIn() {
        store.accountEmail = email
        dismiss()
    }
}
