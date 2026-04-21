//
//  RealtimeDonationService.swift
//  SavePlate
//

import Foundation

protocol RealtimeDonationServiceProtocol: AnyObject {
    func observeAvailableDonations(
        onChange: @escaping ([RealtimeDonation]) -> Void,
        onError: @escaping (String) -> Void
    )
    func observeReceiverHistory(
        userId: String,
        onChange: @escaping ([RealtimeDonation]) -> Void,
        onError: @escaping (String) -> Void
    )
    func observeDonorHistory(
        donorId: String,
        onChange: @escaping ([RealtimeDonation]) -> Void,
        onError: @escaping (String) -> Void
    )
    func observeNotifications(
        userId: String,
        onChange: @escaping ([RealtimeAppNotification]) -> Void,
        onError: @escaping (String) -> Void
    )
    func createDonation(_ donation: RealtimeDonation, forReceivers receiverIds: [String], completion: @escaping (Result<Void, Error>) -> Void)
    func acceptDonation(donationId: String, by user: AppUser, completion: @escaping (Result<Void, Error>) -> Void)
    func markDonationCompleted(donationId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func stopAllObservers()
}

enum RealtimeDonationServiceFactory {
    private static let sharedService: RealtimeDonationServiceProtocol = {
#if canImport(FirebaseFirestore)
        return FirestoreRealtimeDonationService()
#else
        return InMemoryRealtimeDonationService()
#endif
    }()

    static func make() -> RealtimeDonationServiceProtocol {
        sharedService
    }
}

// MARK: - Fallback mock service (single-device preview/testing)

@MainActor
final class InMemoryRealtimeDonationService: RealtimeDonationServiceProtocol {
    private var donations: [RealtimeDonation] = []
    private var notifications: [RealtimeAppNotification] = []
    private var availableHandlers: [([RealtimeDonation]) -> Void] = []
    private var receiverHistoryHandlers: [(String, ([RealtimeDonation]) -> Void)] = []
    private var donorHistoryHandlers: [(String, ([RealtimeDonation]) -> Void)] = []
    private var notificationHandlers: [(String, ([RealtimeAppNotification]) -> Void)] = []

    func observeAvailableDonations(onChange: @escaping ([RealtimeDonation]) -> Void, onError: @escaping (String) -> Void) {
        availableHandlers.append(onChange)
        onChange(donations.filter { $0.status == .available }.sorted { $0.timestamp > $1.timestamp })
    }

    func observeReceiverHistory(userId: String, onChange: @escaping ([RealtimeDonation]) -> Void, onError: @escaping (String) -> Void) {
        receiverHistoryHandlers.append((userId, onChange))
        onChange(receiverHistory(for: userId))
    }

    func observeDonorHistory(donorId: String, onChange: @escaping ([RealtimeDonation]) -> Void, onError: @escaping (String) -> Void) {
        donorHistoryHandlers.append((donorId, onChange))
        onChange(donorHistory(for: donorId))
    }

    func observeNotifications(userId: String, onChange: @escaping ([RealtimeAppNotification]) -> Void, onError: @escaping (String) -> Void) {
        notificationHandlers.append((userId, onChange))
        onChange(notifications.filter { $0.userId == userId }.sorted { $0.createdAt > $1.createdAt })
    }

    func createDonation(_ donation: RealtimeDonation, forReceivers receiverIds: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        donations.insert(donation, at: 0)
        for receiverId in receiverIds {
            notifications.insert(
                RealtimeAppNotification(
                    id: UUID().uuidString,
                    userId: receiverId,
                    title: "New food donation available",
                    body: "\(donation.donorName) donated \(donation.foodDetails)",
                    donationId: donation.id,
                    createdAt: Date(),
                    isRead: false
                ),
                at: 0
            )
        }
        publish()
        completion(.success(()))
    }

    func acceptDonation(donationId: String, by user: AppUser, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let idx = donations.firstIndex(where: { $0.id == donationId }) else {
            completion(.failure(NSError(domain: "local", code: 404, userInfo: [NSLocalizedDescriptionKey: "Donation not found."])))
            return
        }
        guard donations[idx].status == .available else {
            completion(.failure(NSError(domain: "local", code: 409, userInfo: [NSLocalizedDescriptionKey: "Already accepted by another user."])))
            return
        }
        donations[idx].status = .accepted
        donations[idx].acceptedByUserId = user.id
        donations[idx].acceptedByName = user.name
        donations[idx].acceptedByRole = user.role
        donations[idx].acceptedAt = Date()
        publish()
        completion(.success(()))
    }

    func markDonationCompleted(donationId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let idx = donations.firstIndex(where: { $0.id == donationId }) else {
            completion(.failure(NSError(domain: "local", code: 404, userInfo: [NSLocalizedDescriptionKey: "Donation not found."])))
            return
        }
        donations[idx].status = .completed
        donations[idx].completedAt = Date()
        publish()
        completion(.success(()))
    }

    func stopAllObservers() {
        availableHandlers.removeAll()
        receiverHistoryHandlers.removeAll()
        donorHistoryHandlers.removeAll()
        notificationHandlers.removeAll()
    }

    private func publish() {
        let available = donations.filter { $0.status == .available }.sorted { $0.timestamp > $1.timestamp }
        for handler in availableHandlers { handler(available) }
        for (id, handler) in receiverHistoryHandlers { handler(receiverHistory(for: id)) }
        for (id, handler) in donorHistoryHandlers { handler(donorHistory(for: id)) }
        for (id, handler) in notificationHandlers {
            handler(notifications.filter { $0.userId == id }.sorted { $0.createdAt > $1.createdAt })
        }
    }

    private func receiverHistory(for userId: String) -> [RealtimeDonation] {
        donations
            .filter { $0.acceptedByUserId == userId && ($0.status == .accepted || $0.status == .completed) }
            .sorted { ($0.acceptedAt ?? $0.timestamp) > ($1.acceptedAt ?? $1.timestamp) }
    }

    private func donorHistory(for donorId: String) -> [RealtimeDonation] {
        donations.filter { $0.donorId == donorId }.sorted { $0.timestamp > $1.timestamp }
    }
}

#if canImport(FirebaseFirestore)
import FirebaseFirestore

final class FirestoreRealtimeDonationService: RealtimeDonationServiceProtocol {
    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []

    func observeAvailableDonations(onChange: @escaping ([RealtimeDonation]) -> Void, onError: @escaping (String) -> Void) {
        let listener = db.collection("donations")
            .whereField("status", isEqualTo: RealtimeDonationStatus.available.rawValue)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snap, err in
                if let err { onError(err.localizedDescription); return }
                let rows = snap?.documents.compactMap(Self.toDonation) ?? []
                onChange(rows)
            }
        listeners.append(listener)
    }

    func observeReceiverHistory(userId: String, onChange: @escaping ([RealtimeDonation]) -> Void, onError: @escaping (String) -> Void) {
        let listener = db.collection("donations")
            .whereField("acceptedByUserId", isEqualTo: userId)
            .order(by: "acceptedAt", descending: true)
            .addSnapshotListener { snap, err in
                if let err { onError(err.localizedDescription); return }
                let rows = (snap?.documents.compactMap(Self.toDonation) ?? [])
                    .filter { $0.status == .accepted || $0.status == .completed }
                onChange(rows)
            }
        listeners.append(listener)
    }

    func observeDonorHistory(donorId: String, onChange: @escaping ([RealtimeDonation]) -> Void, onError: @escaping (String) -> Void) {
        let listener = db.collection("donations")
            .whereField("donorId", isEqualTo: donorId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snap, err in
                if let err { onError(err.localizedDescription); return }
                onChange(snap?.documents.compactMap(Self.toDonation) ?? [])
            }
        listeners.append(listener)
    }

    func observeNotifications(userId: String, onChange: @escaping ([RealtimeAppNotification]) -> Void, onError: @escaping (String) -> Void) {
        let listener = db.collection("users").document(userId).collection("notifications")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snap, err in
                if let err { onError(err.localizedDescription); return }
                let rows = snap?.documents.compactMap(Self.toNotification) ?? []
                onChange(rows)
            }
        listeners.append(listener)
    }

    func createDonation(_ donation: RealtimeDonation, forReceivers receiverIds: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        let donationRef = db.collection("donations").document(donation.id)
        var batch = db.batch()
        batch.setData(Self.donationData(donation), forDocument: donationRef)
        for rid in receiverIds {
            let notifRef = db.collection("users").document(rid).collection("notifications").document(UUID().uuidString)
            batch.setData([
                "id": notifRef.documentID,
                "userId": rid,
                "title": "New food donation available",
                "body": "\(donation.donorName) donated \(donation.foodDetails)",
                "donationId": donation.id,
                "createdAt": Timestamp(date: Date()),
                "isRead": false
            ], forDocument: notifRef)
        }
        batch.commit { err in
            if let err { completion(.failure(err)); return }
            completion(.success(()))
        }
    }

    func acceptDonation(donationId: String, by user: AppUser, completion: @escaping (Result<Void, Error>) -> Void) {
        let ref = db.collection("donations").document(donationId)
        db.runTransaction({ tx, errPointer in
            do {
                let snap = try tx.getDocument(ref)
                guard let status = snap.data()?["status"] as? String, status == RealtimeDonationStatus.available.rawValue else {
                    errPointer?.pointee = NSError(domain: "firestore", code: 409, userInfo: [NSLocalizedDescriptionKey: "Already accepted by another user."])
                    return nil
                }
                tx.updateData([
                    "status": RealtimeDonationStatus.accepted.rawValue,
                    "acceptedByUserId": user.id,
                    "acceptedByName": user.name,
                    "acceptedByRole": user.role.rawValue,
                    "acceptedAt": Timestamp(date: Date())
                ], forDocument: ref)
                return nil
            } catch {
                errPointer?.pointee = error as NSError
                return nil
            }
        }) { _, error in
            if let error { completion(.failure(error)); return }
            completion(.success(()))
        }
    }

    func markDonationCompleted(donationId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("donations").document(donationId).updateData([
            "status": RealtimeDonationStatus.completed.rawValue,
            "completedAt": Timestamp(date: Date())
        ]) { err in
            if let err { completion(.failure(err)); return }
            completion(.success(()))
        }
    }

    func stopAllObservers() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }

    private static func donationData(_ d: RealtimeDonation) -> [String: Any] {
        [
            "id": d.id,
            "donorId": d.donorId,
            "donorName": d.donorName,
            "foodDetails": d.foodDetails,
            "quantity": d.quantity,
            "latitude": d.latitude,
            "longitude": d.longitude,
            "status": d.status.rawValue,
            "acceptedByUserId": d.acceptedByUserId as Any,
            "acceptedByName": d.acceptedByName as Any,
            "acceptedByRole": d.acceptedByRole?.rawValue as Any,
            "timestamp": Timestamp(date: d.timestamp),
            "acceptedAt": d.acceptedAt.map(Timestamp.init(date:)) as Any,
            "completedAt": d.completedAt.map(Timestamp.init(date:)) as Any
        ]
    }

    private static func toDonation(from doc: QueryDocumentSnapshot) -> RealtimeDonation? {
        let data = doc.data()
        guard
            let donorId = data["donorId"] as? String,
            let donorName = data["donorName"] as? String,
            let foodDetails = data["foodDetails"] as? String,
            let quantity = data["quantity"] as? String,
            let latitude = data["latitude"] as? Double,
            let longitude = data["longitude"] as? Double,
            let statusRaw = data["status"] as? String,
            let status = RealtimeDonationStatus(rawValue: statusRaw),
            let timestamp = data["timestamp"] as? Timestamp
        else { return nil }

        let acceptedRole: AppUserRole?
        if let roleRaw = data["acceptedByRole"] as? String {
            acceptedRole = AppUserRole(rawValue: roleRaw)
        } else {
            acceptedRole = nil
        }

        return RealtimeDonation(
            id: doc.documentID,
            donorId: donorId,
            donorName: donorName,
            foodDetails: foodDetails,
            quantity: quantity,
            latitude: latitude,
            longitude: longitude,
            status: status,
            acceptedByUserId: data["acceptedByUserId"] as? String,
            acceptedByName: data["acceptedByName"] as? String,
            acceptedByRole: acceptedRole,
            timestamp: timestamp.dateValue(),
            acceptedAt: (data["acceptedAt"] as? Timestamp)?.dateValue(),
            completedAt: (data["completedAt"] as? Timestamp)?.dateValue()
        )
    }

    private static func toNotification(from doc: QueryDocumentSnapshot) -> RealtimeAppNotification? {
        let data = doc.data()
        guard
            let userId = data["userId"] as? String,
            let title = data["title"] as? String,
            let body = data["body"] as? String,
            let createdAt = data["createdAt"] as? Timestamp,
            let isRead = data["isRead"] as? Bool
        else { return nil }
        return RealtimeAppNotification(
            id: doc.documentID,
            userId: userId,
            title: title,
            body: body,
            donationId: data["donationId"] as? String,
            createdAt: createdAt.dateValue(),
            isRead: isRead
        )
    }
}
#endif

