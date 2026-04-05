//
//  DonationsMapView.swift
//  SavePlate
//

import MapKit
import SwiftUI

struct DonationsMapView: View {
    @Environment(DonationStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var position: MapCameraPosition = .automatic

    private var annotated: [Donation] {
        store.donations.filter { $0.isActive && $0.coordinate != nil }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Map(position: $position) {
                    ForEach(annotated) { d in
                        if let c = d.coordinate {
                            Annotation(d.foodName, coordinate: c) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, SPColor.leaf)
                            }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))

                if annotated.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "map")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No pinned active donations")
                            .font(.headline)
                        Text("Add coordinates when you list food to show it here.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding()
                }
            }
            .navigationTitle("Near you")
            .navigationBarTitleDisplayMode(.inline)
            .hearthNavBar()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Fit all") {
                        fitAll()
                    }
                    .disabled(annotated.isEmpty)
                }
            }
            .onAppear { fitAll() }
        }
    }

    private func fitAll() {
        guard !annotated.isEmpty else {
            position = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 12.97, longitude: 77.59),
                span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
            ))
            return
        }
        let coords = annotated.compactMap(\.coordinate)
        var minLat = coords[0].latitude
        var maxLat = coords[0].latitude
        var minLon = coords[0].longitude
        var maxLon = coords[0].longitude
        for c in coords.dropFirst() {
            minLat = min(minLat, c.latitude)
            maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude)
            maxLon = max(maxLon, c.longitude)
        }
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.4, 0.02),
            longitudeDelta: max((maxLon - minLon) * 1.4, 0.02)
        )
        position = .region(MKCoordinateRegion(center: center, span: span))
    }
}

#Preview {
    DonationsMapView()
        .environment(DonationStore())
}
