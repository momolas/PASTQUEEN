//
//  LocationManager.swift
//  PASTQUEEN
//
//  Created by Jules on 26/10/2025.
//

import Foundation
import CoreLocation
import Observation

import SwiftUI

@MainActor
protocol AppLocationService: AnyObject, Observable {
    var altitude: Double? { get set }
    var location: CLLocation? { get set }
    var authorizationStatus: CLAuthorizationStatus { get set }
    var errorMessage: String? { get set }

    func requestLocation()
}

@MainActor
@Observable
class LocationManager: NSObject, AppLocationService, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var altitude: Double?
    var location: CLLocation?
    var authorizationStatus: CLAuthorizationStatus
    var errorMessage: String?

    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        self.errorMessage = nil
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            Task { @MainActor in
                self.location = location
                self.altitude = location.altitude
                manager.stopUpdatingLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error)")
        Task { @MainActor in
            self.errorMessage = error.localizedDescription
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
        }
    }
}

extension EnvironmentValues {
    @Entry var locationService: (any AppLocationService)? = nil
}
