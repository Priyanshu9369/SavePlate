//
//  AppSession.swift
//  SavePlate
//

import Foundation

enum AppPrimaryPath: String, CaseIterable, Codable {
    case landing
    case donor
    case receiver
}

@MainActor
@Observable
final class AppSession {
    private let pathKey = "hearth.primaryPath.v1"

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
        if let raw = UserDefaults.standard.string(forKey: pathKey),
           let p = AppPrimaryPath(rawValue: raw), p != .landing {
            path = p
        } else {
            path = .landing
        }
    }

    func chooseDonor() {
        path = .donor
    }

    func chooseReceiver() {
        path = .receiver
    }

    func returnToLanding() {
        path = .landing
    }
}
