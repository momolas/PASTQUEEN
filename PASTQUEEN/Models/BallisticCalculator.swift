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
    
    public func solveTrajectory(for distance: Double) -> [Double] {
        if let point = solveFullTrajectory(upTo: distance).getPoint(at: Measurement(value: distance, unit: UnitLength.meters)) {
            return [
                distance,
                point.drop.converted(to: UnitLength.centimeters).value,
                point.dropCorrection,
                point.seconds,
                point.windage.converted(to: UnitLength.centimeters).value,
                point.windageCorrection,
                point.velocity.converted(to: UnitSpeed.metersPerSecond).value,
                point.energy.converted(to: UnitEnergy.joules).value
            ]
        }
        return Array(repeating: 0.0, count: 8)
    }
    
    public func solveFullTrajectory(upTo distance: Double) -> Ballistics.BallisticSolution {
        let dragModel: Ballistics.DragModel
        switch ballistics.dragFunction {
        case 1: dragModel = .G1
        case 2: dragModel = .G2
        case 5: dragModel = .G5
        case 6: dragModel = .G6
        case 7: dragModel = .G7
        case 8: dragModel = .G8
        default: dragModel = .G1
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
                temperature: Measurement(value: weather.temperature, unit: UnitTemperature.celsius),
                relativeHumidity: weather.humidity,
                pressure: Measurement(value: weather.pressure, unit: UnitPressure.hectopascals)
            ),
            windSpeed: Measurement(value: weather.windSpeed, unit: UnitSpeed.kilometersPerHour),
            windAngle: weather.windDirection,
            weight: Measurement(value: ballistics.projectileWeightGrains, unit: UnitMass.grains)
        )
    }
}
