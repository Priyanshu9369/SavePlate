//
//  AuthManager.swift
//  Mock donor authentication (MVVM-friendly observable model).
//

import Foundation

@MainActor
@Observable
final class AuthManager {
    private let loggedInKey = "hearth.auth.loggedIn"
    private let identifierKey = "hearth.auth.identifier"
    private let displayNameKey = "hearth.auth.displayName"
    private let usersKey = "hearth.auth.mockUsers"

    /// When `true`, the donor tab shell (dashboard) is shown.
    private(set) var isAuthenticated: Bool {
        didSet {
            UserDefaults.standard.set(isAuthenticated, forKey: loggedInKey)
        }
    }

    /// Last signed-in email or phone (for display).
    private(set) var currentUserIdentifier: String? {
        didSet {
            if let id = currentUserIdentifier {
                UserDefaults.standard.set(id, forKey: identifierKey)
            } else {
                UserDefaults.standard.removeObject(forKey: identifierKey)
            }
        }
    }

    /// Optional donor name for profile usage.
    private(set) var currentUserDisplayName: String? {
        didSet {
            if let name = currentUserDisplayName {
                UserDefaults.standard.set(name, forKey: displayNameKey)
            } else {
                UserDefaults.standard.removeObject(forKey: displayNameKey)
            }
        }
    }

    /// Backward-compatible alias used elsewhere in UI.
    var currentUserEmail: String? { currentUserIdentifier }

    /// Normalized identifier (email/phone) -> donor record.
    private var mockUsers: [String: MockUser] = [:]

    init() {
        isAuthenticated = UserDefaults.standard.bool(forKey: loggedInKey)
        currentUserIdentifier = UserDefaults.standard.string(forKey: identifierKey)
        currentUserDisplayName = UserDefaults.standard.string(forKey: displayNameKey)
        if let data = UserDefaults.standard.data(forKey: usersKey),
           let decoded = try? JSONDecoder().decode([String: MockUser].self, from: data) {
            mockUsers = decoded
        }
    }

    private func persistUsers() {
        if let data = try? JSONEncoder().encode(mockUsers) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }

    /// Register a new donor account (mock) with email or phone.
    @discardableResult
    func register(name: String, identifier: String, password: String) -> String? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return "Please enter your name."
        }
        guard isValidIdentifier(identifier), password.count >= 6 else {
            return "Enter a valid email or phone number and a password of at least 6 characters."
        }
        let key = normalizedIdentifier(identifier)
        guard mockUsers[key] == nil else {
            return "An account already exists for this email or phone. Sign in instead."
        }
        mockUsers[key] = MockUser(name: trimmedName, identifier: identifier.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
        persistUsers()
        return nil
    }

    /// Sign in with mock credentials using email or phone.
    @discardableResult
    func login(identifier: String, password: String) -> String? {
        let key = normalizedIdentifier(identifier)
        guard let stored = mockUsers[key], stored.password == password else {
            return "Email/phone or password is incorrect."
        }
        currentUserIdentifier = stored.identifier
        currentUserDisplayName = stored.name
        isAuthenticated = true
        return nil
    }

    /// Demo Google sign in (mock).
    func loginWithGoogle() {
        let demoIdentifier = "google.user@demo.com"
        let key = normalizedIdentifier(demoIdentifier)
        if mockUsers[key] == nil {
            mockUsers[key] = MockUser(name: "Google Donor", identifier: demoIdentifier, password: UUID().uuidString)
            persistUsers()
        }
        currentUserIdentifier = demoIdentifier
        currentUserDisplayName = mockUsers[key]?.name
        isAuthenticated = true
    }

    func isValidIdentifier(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return isValidEmail(trimmed) || isValidPhone(trimmed)
    }

    func logout() {
        isAuthenticated = false
        currentUserIdentifier = nil
        currentUserDisplayName = nil
    }

    private func normalizedIdentifier(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if isValidEmail(trimmed) {
            return trimmed.lowercased()
        }
        return trimmed.filter(\.isNumber)
    }

    private func isValidEmail(_ value: String) -> Bool {
        let regex = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return value.range(of: regex, options: .regularExpression) != nil
    }

    private func isValidPhone(_ value: String) -> Bool {
        let digits = value.filter(\.isNumber)
        return digits.count >= 10 && digits.count <= 15
    }
}

private struct MockUser: Codable {
    var name: String
    var identifier: String
    var password: String
}
