//
//  BallisticCalculator.swift
//  PASTQUEEN
//
//  Created by Jules on 26/10/2025.
//

import Foundation
import Ballistics


struct BallisticCalculator {
    
    // Input parameters from the Ballistics model
    private let ballistics: BallisticSettings

    // Weather and environmental conditions
    private let weather: WeatherData
    
    struct WeatherData {
        var windSpeed: Double = 0.0
        var windDirection: Double = 0.0
        var pressure: Double = 1013.25
        var temperature: Double = 15.0
        var humidity: Double = 0.78
        var altitude: Double = 0.0
    }
    
    init(ballistics: BallisticSettings, weather: WeatherData) {
        self.ballistics = ballistics
        self.weather = weather
    }
    
    public func solveTrajectory(for distance: Double) -> TrajectoryResult {
        if let point = solveFullTrajectory(upTo: distance).getPoint(at: Measurement(value: distance, unit: UnitLength.meters)) {
            return TrajectoryResult(
                distance: distance,
                dropCM: point.drop.converted(to: .centimeters).value,
                dropCorrectionMOA: point.dropCorrection.converted(to: .degrees).value * 60.0,
                timeSeconds: point.travelTime.converted(to: .seconds).value,
                windageCM: point.windage.converted(to: .centimeters).value,
                windageCorrectionMOA: point.windageCorrection.converted(to: .degrees).value * 60.0,
                velocityMPS: point.velocity.converted(to: .metersPerSecond).value,
                energyJoules: point.energy.converted(to: .joules).value
            )
        }
        return .empty
    }
    
    public func solveFullTrajectory(upTo distance: Double) -> Ballistics {
        let effectiveBC: Double
        if ballistics.dragFunction == 7 {
            effectiveBC = ballistics.ballisticCoefficient * 1.95
        } else {
            effectiveBC = ballistics.ballisticCoefficient
        }

        return Ballistics.solve(
            dragCoefficient: effectiveBC,
            initialVelocity: Measurement(value: ballistics.muzzleVelocityMPS, unit: UnitSpeed.metersPerSecond),
            sightHeight: Measurement(value: ballistics.sightHeightCM, unit: UnitLength.centimeters),
            shootingAngle: Measurement(value: 0, unit: UnitAngle.degrees),
            zeroRange: Measurement(value: ballistics.zeroRangeMeters, unit: UnitLength.meters),
            atmosphere: Atmosphere(
                altitude: Measurement(value: weather.altitude, unit: UnitLength.meters),
 				pressure: Measurement(value: weather.pressure, unit: UnitPressure.hectopascals),
                temperature: Measurement(value: weather.temperature, unit: UnitTemperature.celsius),
                relativeHumidity: weather.humidity,
            ),
            windSpeed: Measurement(value: weather.windSpeed, unit: UnitSpeed.kilometersPerHour),
            windAngle: weather.windDirection,
            weight: Measurement(value: ballistics.projectileWeightGrains, unit: UnitMass.grains)
        )
    }
}

struct BallisticSettings: Equatable, Sendable, Identifiable {
    var ammunitionName: String
    var ballisticCoefficient: Double
    var calibre: String
    var date: Double
    var distanceMeters: Double
    var dragFunction: Int32
    var id: UUID
    var muzzleEnergy: Double
    var muzzleVelocityMPS: Double
    var projectileManufacturer: String
    var projectileWeightGrains: Double
    var sightHeightCM: Double
    var zeroRangeMeters: Double

    init(ammunitionName: String, ballisticCoefficient: Double, calibre: String, date: Double, distanceMeters: Double, dragFunction: Int32, id: UUID, muzzleEnergy: Double, muzzleVelocityMPS: Double, projectileManufacturer: String, projectileWeightGrains: Double, sightHeightCM: Double, zeroRangeMeters: Double) {
        self.ammunitionName = ammunitionName
        self.ballisticCoefficient = ballisticCoefficient
        self.calibre = calibre
        self.date = date
        self.distanceMeters = distanceMeters
        self.dragFunction = dragFunction
        self.id = id
        self.muzzleEnergy = muzzleEnergy
        self.muzzleVelocityMPS = muzzleVelocityMPS
        self.projectileManufacturer = projectileManufacturer
        self.projectileWeightGrains = projectileWeightGrains
        self.sightHeightCM = sightHeightCM
        self.zeroRangeMeters = zeroRangeMeters
    }
}
