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
    private let ballistics: Ballistics

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
    
    init(ballistics: Ballistics, weather: WeatherData) {
        self.ballistics = ballistics
        self.weather = weather
    }
    
    public func solveTrajectory(for distance: Double) -> [Double] {
        if let point = solveFullTrajectory(upTo: distance).getPoint(at: Measurement(value: distance, unit: .meters)) {
            return [
                distance,
                point.drop.converted(to: .centimeters).value,
                point.dropCorrection,
                point.seconds,
                point.windage.converted(to: .centimeters).value,
                point.windageCorrection,
                point.velocity.converted(to: .metersPerSecond).value,
                point.energy.converted(to: .joules).value
            ]
        }
        return Array(repeating: 0.0, count: 8)
    }
    
    public func solveFullTrajectory(upTo distance: Double) -> BallisticSolution {
        let dragModel: DragModel
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
            initialVelocity: Measurement(value: ballistics.muzzleVelocityMPS, unit: .metersPerSecond),
            sightHeight: Measurement(value: ballistics.sightHeightCM, unit: .centimeters),
            shootingAngle: Measurement(value: 0, unit: .degrees),
            zeroRange: Measurement(value: ballistics.zeroRangeMeters, unit: .meters),
            atmosphere: Atmosphere(
                altitude: Measurement(value: weather.altitude, unit: .meters),
                temperature: Measurement(value: weather.temperature, unit: .celsius),
                relativeHumidity: weather.humidity,
                pressure: Measurement(value: weather.pressure, unit: .hectopascals)
            ),
            windSpeed: Measurement(value: weather.windSpeed, unit: .kilometersPerHour),
            windAngle: weather.windDirection,
            weight: Measurement(value: ballistics.projectileWeightGrains, unit: .grains)
        )
    }
}
