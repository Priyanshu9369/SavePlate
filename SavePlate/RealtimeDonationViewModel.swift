//
//  RealtimeDonationViewModel.swift
//  SavePlate
//

import Foundation

@MainActor
@Observable
final class RealtimeDonationViewModel {
    var availableFeed: [RealtimeDonation] = []
    var receiverHistory: [RealtimeDonation] = []
    var donorHistory: [RealtimeDonation] = []
    var notifications: [RealtimeAppNotification] = []

    var isLoading = false
    var bannerMessage: String?
    var errorMessage: String?

    let currentUser: AppUser
    private let service: RealtimeDonationServiceProtocol

    init(currentUser: AppUser, service: RealtimeDonationServiceProtocol = RealtimeDonationServiceFactory.make()) {
        self.currentUser = currentUser
        self.service = service
    }

    deinit {
        service.stopAllObservers()
    }

    func start(receiverNotificationTargets: [String] = []) {
        service.observeAvailableDonations { [weak self] rows in
            self?.availableFeed = rows
        } onError: { [weak self] err in
            self?.errorMessage = err
        }

        service.observeNotifications(userId: currentUser.id) { [weak self] rows in
            self?.notifications = rows
        } onError: { [weak self] err in
            self?.errorMessage = err
        }

        if currentUser.role == .donor {
            service.observeDonorHistory(userIdOrDonorId: currentUser.id, onChange: { [weak self] rows in
                self?.donorHistory = rows
            }, onError: { [weak self] err in
                self?.errorMessage = err
            })
        } else {
            service.observeReceiverHistory(userId: currentUser.id) { [weak self] rows in
                self?.receiverHistory = rows
            } onError: { [weak self] err in
                self?.errorMessage = err
            }
        }
    }

    func createDonation(
        foodDetails: String,
        quantity: String,
        latitude: Double,
        longitude: Double,
        receiverIds: [String]
    ) {
        isLoading = true
        let d = RealtimeDonation(
            id: UUID().uuidString,
            donorId: currentUser.id,
            donorName: currentUser.name,
            foodDetails: foodDetails,
            quantity: quantity,
            latitude: latitude,
            longitude: longitude,
            status: .available,
            acceptedByUserId: nil,
            acceptedByName: nil,
            acceptedByRole: nil,
            timestamp: Date(),
            acceptedAt: nil,
            completedAt: nil
        )
        service.createDonation(d, forReceivers: receiverIds) { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success:
                self.bannerMessage = "Donation posted in real time."
            case .failure(let err):
                self.errorMessage = err.localizedDescription
            }
        }
    }

    func acceptDonation(_ donation: RealtimeDonation) {
        isLoading = true
        service.acceptDonation(donationId: donation.id, by: currentUser) { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success:
                self.bannerMessage = "Donation accepted."
            case .failure(let err):
                self.errorMessage = err.localizedDescription
            }
        }
    }

    func completeDonation(_ donation: RealtimeDonation) {
        isLoading = true
        service.markDonationCompleted(donationId: donation.id) { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success:
                self.bannerMessage = "Donation marked completed."
            case .failure(let err):
                self.errorMessage = err.localizedDescription
            }
        }
    }
}

private extension RealtimeDonationServiceProtocol {
    func observeDonorHistory(
        userIdOrDonorId: String,
        onChange: @escaping ([RealtimeDonation]) -> Void,
        onError: @escaping (String) -> Void
    ) {
        observeDonorHistory(donorId: userIdOrDonorId, onChange: onChange, onError: onError)
    }
}

