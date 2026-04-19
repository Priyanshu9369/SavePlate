//
//  AppSession.swift
//  SavePlate
//

import Foundation

enum AppPrimaryPath: String, CaseIterable, Codable {
    case landing
    case donor
    /// Second step for “I need food”: choose NGO vs Individual.
    case receiverOnboarding
    case receiverNGO
    case receiverIndividual
}

@MainActor
@Observable
final class AppSession {
    private let pathKey = "hearth.primaryPath.v2"

    var path: AppPrimaryPath {
        didSet {
            if path == .landing {
                UserDefaults.standard.removeObject(forKey: pathKey)
            } else {
                UserDefaults.standard.set(path.rawValue, forKey: pathKey)
            }
        }
    }

    init() {
        if let raw = UserDefaults.standard.string(forKey: pathKey) {
            if raw == "receiver" {
                path = .receiverOnboarding
                UserDefaults.standard.set(AppPrimaryPath.receiverOnboarding.rawValue, forKey: pathKey)
            } else if let p = AppPrimaryPath(rawValue: raw), p != .landing {
                path = p
            } else {
                path = .landing
            }
        } else {
            path = .landing
        }
    }

    func chooseDonor() {
        path = .donor
    }

    /// Landing → receiver path: NGO vs Individual (second screen).
    func chooseReceiverOnboarding() {
        path = .receiverOnboarding
    }

    func chooseReceiverNGO() {
        path = .receiverNGO
    }

    func chooseReceiverIndividual() {
        path = .receiverIndividual
    }

    func returnToLanding() {
        path = .landing
    }

    func returnToReceiverOnboarding() {
        path = .receiverOnboarding
    }

    var isNGOReceiver: Bool {
        path == .receiverNGO
    }
}
