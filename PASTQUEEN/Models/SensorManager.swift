//
//  SensorManager.swift
//  PASTQUEEN
//

import Foundation
import CoreMotion
import Observation
import SwiftUI

@MainActor
@Observable
class SensorManager {
    private let altimeter = CMAltimeter()
    var isSensorAvailable: Bool { CMAltimeter.isRelativeAltitudeAvailable() }
    var currentPressureHPa: Double? = nil
    var isMonitoring = false
    
    func startMonitoring() {
        guard isSensorAvailable else { return }
        guard !isMonitoring else { return }
        isMonitoring = true
        altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else { return }
            // pressure is returned in kilopascals (kPa), convert to hectopascals (hPa) by multiplying by 10
            let pressureKPa = data.pressure.doubleValue
            self.currentPressureHPa = pressureKPa * 10.0
        }
    }
    
    func stopMonitoring() {
        guard isMonitoring else { return }
        altimeter.stopRelativeAltitudeUpdates()
        isMonitoring = false
    }
}

extension EnvironmentValues {
    @Entry var sensorService: SensorManager? = nil
}
