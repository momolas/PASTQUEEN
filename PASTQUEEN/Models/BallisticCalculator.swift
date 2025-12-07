//
//  BallisticCalculator.swift
//  PASTQUEEN
//
//  Created by Jules on 26/10/2025.
//

import Foundation
import SwiftBallistics

struct TrajectoryResult {
    let distance: Double
    let dropCM: Double
    let dropCorrectionMOA: Double
    let timeSeconds: Double
    let windageCM: Double
    let windageCorrectionMOA: Double
    let velocityMPS: Double
    let energyJoules: Double

    static var empty: TrajectoryResult {
        TrajectoryResult(
            distance: 0,
            dropCM: 0,
            dropCorrectionMOA: 0,
            timeSeconds: 0,
            windageCM: 0,
            windageCorrectionMOA: 0,
            velocityMPS: 0,
            energyJoules: 0
        )
    }
}

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
                dropCM: point.drop.converted(to: UnitLength.centimeters).value,
                dropCorrectionMOA: point.dropCorrection,
                timeSeconds: point.seconds,
                windageCM: point.windage.converted(to: UnitLength.centimeters).value,
                windageCorrectionMOA: point.windageCorrection,
                velocityMPS: point.velocity.converted(to: UnitSpeed.metersPerSecond).value,
                energyJoules: point.energy.converted(to: UnitEnergy.joules).value
            )
        }
        return .empty
    }
    
    public func solveFullTrajectory(upTo distance: Double) -> Ballistics {
        let dragModel: DragModel
        switch ballistics.dragFunction {
        case 1: dragModel = .g1
        case 2: dragModel = .g2
        case 5: dragModel = .g5
        case 6: dragModel = .g6
        case 7: dragModel = .g7
        case 8: dragModel = .g8
        default: dragModel = .g1
        }
        
        return Ballistics.solve(
            dragModel: dragModel,
            ballisticCoefficient: ballistics.ballisticCoefficient,
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
