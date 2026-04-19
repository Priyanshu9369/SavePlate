//
//  AuthManager.swift
//  Mock donor authentication (MVVM-friendly observable model).
//

import Foundation

@MainActor
@Observable
final class AuthManager {
    private let loggedInKey = "hearth.auth.loggedIn"
    private let emailKey = "hearth.auth.email"
    private let usersKey = "hearth.auth.mockUsers"

    /// When `true`, the donor tab shell (dashboard) is shown.
    private(set) var isAuthenticated: Bool {
        didSet {
            UserDefaults.standard.set(isAuthenticated, forKey: loggedInKey)
        }
    }

    /// Last signed-in email (for display).
    private(set) var currentUserEmail: String? {
        didSet {
            if let e = currentUserEmail {
                UserDefaults.standard.set(e, forKey: emailKey)
            } else {
                UserDefaults.standard.removeObject(forKey: emailKey)
            }
        }
    }

    /// Lowercased email → password (demo only — never do this with a real backend).
    private var mockUsers: [String: String] = [:]

    init() {
        isAuthenticated = UserDefaults.standard.bool(forKey: loggedInKey)
        currentUserEmail = UserDefaults.standard.string(forKey: emailKey)
        if let data = UserDefaults.standard.data(forKey: usersKey),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            mockUsers = decoded
        }
    }

    private func persistUsers() {
        if let data = try? JSONEncoder().encode(mockUsers) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }

    /// Register a new donor account (mock).
    @discardableResult
    func register(email: String, password: String) -> String? {
        let e = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard e.contains("@"), password.count >= 6 else {
            return "Enter a valid email and a password of at least 6 characters."
        }
        guard mockUsers[e] == nil else {
            return "An account already exists for this email. Sign in instead."
        }
        mockUsers[e] = password
        persistUsers()
        return nil
    }

    /// Sign in with mock credentials.
    @discardableResult
    func login(email: String, password: String) -> String? {
        let e = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let stored = mockUsers[e], stored == password else {
            return "Email or password is incorrect."
        }
        currentUserEmail = e
        isAuthenticated = true
        return nil
    }

    func logout() {
        isAuthenticated = false
        currentUserEmail = nil
    }
}
