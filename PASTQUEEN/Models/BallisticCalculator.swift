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
        return Ballistics.solve(
            dragCoefficient: ballistics.ballisticCoefficient,
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
