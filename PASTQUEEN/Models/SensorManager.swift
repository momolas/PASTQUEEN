//
//  SensorManager.swift
//  PASTQUEEN
//
//  Created by Mo on 30/05/2026.
//

import Foundation
import CoreMotion
import Observation
import SwiftUI

@MainActor
@Observable
class SensorManager {
    private let altimeter = CMAltimeter()
    private let motionManager = CMMotionManager()

    var isSensorAvailable: Bool { CMAltimeter.isRelativeAltitudeAvailable() }
    var isMotionAvailable: Bool { motionManager.isDeviceMotionAvailable }
    
    var currentPressureHPa: Double? = nil
    var currentInclineDegrees: Double? = nil
    
    var isMonitoringPressure = false
    var isMonitoringIncline = false
    
    func startMonitoring() {
        guard isSensorAvailable else { return }
        guard !isMonitoringPressure else { return }
        isMonitoringPressure = true
        altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else { return }
            // pressure is returned in kilopascals (kPa), convert to hectopascals (hPa) by multiplying by 10
            let pressureKPa = data.pressure.doubleValue
            self.currentPressureHPa = pressureKPa * 10.0
        }
    }
    
    func stopMonitoring() {
        guard isMonitoringPressure else { return }
        altimeter.stopRelativeAltitudeUpdates()
        isMonitoringPressure = false
    }

    func startInclineMonitoring() {
        guard isMotionAvailable else { return }
        guard !isMonitoringIncline else { return }
        isMonitoringIncline = true
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion, error == nil else { return }
            // Pitch in radians converted to degrees (pointing device forward/up/down)
            let pitchDegrees = motion.attitude.pitch * 180.0 / .pi
            self.currentInclineDegrees = pitchDegrees
        }
    }

    func stopInclineMonitoring() {
        guard isMonitoringIncline else { return }
        motionManager.stopDeviceMotionUpdates()
        isMonitoringIncline = false
    }
}

extension EnvironmentValues {
    @Entry var sensorService: SensorManager? = nil
}
