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
    var latitude: Double? { get }
    var headingDegrees: Double? { get set }
    var authorizationStatus: CLAuthorizationStatus { get set }
    var errorMessage: String? { get set }

    func requestLocation()
    func startUpdatingHeading()
    func stopUpdatingHeading()
}

@MainActor
@Observable
class LocationManager: NSObject, AppLocationService, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var altitude: Double?
    var location: CLLocation?
    var headingDegrees: Double?
    var authorizationStatus: CLAuthorizationStatus
    var errorMessage: String?

    var latitude: Double? {
        location?.coordinate.latitude
    }

    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = 1.0
    }

    func requestLocation() {
        self.errorMessage = nil
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func startUpdatingHeading() {
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }

    func stopUpdatingHeading() {
        if CLLocationManager.headingAvailable() {
            locationManager.stopUpdatingHeading()
        }
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

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let degrees = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        Task { @MainActor in
            self.headingDegrees = degrees
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

