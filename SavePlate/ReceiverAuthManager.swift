//
//  ReceiverAuthManager.swift
//  Mock receiver ("I need food") auth — separate from donor AuthManager.
//

import Foundation

private struct ReceiverStoredAccount: Codable, Equatable {
    var password: String
    var displayName: String
    var kind: ReceiverAuthKind
}

@MainActor
@Observable
final class ReceiverAuthManager {
    private let loggedInKey = "hearth.receiver.loggedIn"
    private let identifierKey = "hearth.receiver.identifier"
    private let displayNameKey = "hearth.receiver.displayName"
    private let kindKey = "hearth.receiver.kind"
    private let accountsKey = "hearth.receiver.mockAccounts"

    private(set) var isAuthenticated: Bool {
        didSet { UserDefaults.standard.set(isAuthenticated, forKey: loggedInKey) }
    }

    /// Email or mobile used at sign-in (normalized for lookup).
    private(set) var currentIdentifier: String? {
        didSet {
            if let id = currentIdentifier {
                UserDefaults.standard.set(id, forKey: identifierKey)
            } else {
                UserDefaults.standard.removeObject(forKey: identifierKey)
            }
        }
    }

    private(set) var currentDisplayName: String? {
        didSet {
            if let n = currentDisplayName {
                UserDefaults.standard.set(n, forKey: displayNameKey)
            } else {
                UserDefaults.standard.removeObject(forKey: displayNameKey)
            }
        }
    }

    private(set) var currentKind: ReceiverAuthKind? {
        didSet {
            if let k = currentKind {
                UserDefaults.standard.set(k.rawValue, forKey: kindKey)
            } else {
                UserDefaults.standard.removeObject(forKey: kindKey)
            }
        }
    }

    private var accounts: [String: ReceiverStoredAccount] = [:]

    init() {
        isAuthenticated = UserDefaults.standard.bool(forKey: loggedInKey)
        currentIdentifier = UserDefaults.standard.string(forKey: identifierKey)
        currentDisplayName = UserDefaults.standard.string(forKey: displayNameKey)
        if let raw = UserDefaults.standard.string(forKey: kindKey),
           let k = ReceiverAuthKind(rawValue: raw) {
            currentKind = k
        }
        if let data = UserDefaults.standard.data(forKey: accountsKey),
           let decoded = try? JSONDecoder().decode([String: ReceiverStoredAccount].self, from: data) {
            accounts = decoded
        }
    }

    private func persistAccounts() {
        if let data = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(data, forKey: accountsKey)
        }
    }

    private static func accountKey(kind: ReceiverAuthKind, identifier: String) -> String {
        "\(kind.rawValue)|\(normalizedIdentifier(identifier))"
    }

    /// Lowercase email, or digits-only for phone-style input.
    static func normalizedIdentifier(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()
        if lower.contains("@") { return lower }
        let digits = trimmed.filter(\.isNumber)
        return digits.isEmpty ? lower : digits
    }

    /// Basic check: looks like email or has enough digits for a phone.
    static func isValidIdentifier(_ raw: String) -> Bool {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.contains("@"), t.contains(".") { return true }
        let digits = t.filter(\.isNumber)
        return digits.count >= 10
    }

    @discardableResult
    func register(kind: ReceiverAuthKind, displayName: String, identifier: String, password: String) -> String? {
        let name = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard name.count >= 2 else {
            return kind == .ngo ? "Enter your organization name." : "Enter your name."
        }
        guard Self.isValidIdentifier(identifier) else {
            return "Enter a valid email or a mobile number with at least 10 digits."
        }
        guard password.count >= 6 else {
            return "Password must be at least 6 characters."
        }
        let key = Self.accountKey(kind: kind, identifier: identifier)
        guard accounts[key] == nil else {
            return "An account already exists for this role and email or phone. Sign in instead."
        }
        accounts[key] = ReceiverStoredAccount(password: password, displayName: name, kind: kind)
        persistAccounts()
        return nil
    }

    @discardableResult
    func login(kind: ReceiverAuthKind, identifier: String, password: String) -> String? {
        guard Self.isValidIdentifier(identifier) else {
            return "Enter a valid email or mobile number."
        }
        let key = Self.accountKey(kind: kind, identifier: identifier)
        guard let stored = accounts[key], stored.password == password else {
            let other: ReceiverAuthKind = (kind == .ngo) ? .individual : .ngo
            let otherKey = Self.accountKey(kind: other, identifier: identifier)
            if let otherAcct = accounts[otherKey], otherAcct.password == password {
                return "This account is registered as \(other.title). Switch the account type above."
            }
            return "Account not found or password incorrect for \(kind.title)."
        }
        guard stored.kind == kind else { return "Sign-in failed." }
        currentIdentifier = Self.normalizedIdentifier(identifier)
        currentDisplayName = stored.displayName
        currentKind = kind
        isAuthenticated = true
        return nil
    }

    func logout() {
        isAuthenticated = false
        currentIdentifier = nil
        currentDisplayName = nil
        currentKind = nil
    }

    /// Applies profile fields to `DonationStore` after sign-in / register.
    func syncToStore(_ store: DonationStore) {
        if let name = currentDisplayName, !name.isEmpty {
            store.receiverProfileName = name
        }
        if let kind = currentKind {
            store.receiverAvatarSymbol = (kind == .ngo) ? "building.2.fill" : "person.fill"
            store.receiverBio = (kind == .ngo)
                ? "Verified NGO receiver serving the needy with transparent community distribution."
                : "Verified individual receiver helping ensure food reaches nearby families in need."
        }
        if let id = currentIdentifier {
            if id.contains("@") {
                store.accountEmail = id
            } else {
                store.accountEmail = ""
            }
        }
    }
}
