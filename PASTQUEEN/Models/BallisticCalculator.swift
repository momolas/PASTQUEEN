//
//  BallisticCalculator.swift
//  PASTQUEEN
//
//  Created by Jules on 26/10/2025.
//

import Foundation
import Ballistics

struct BallisticCalculator: Sendable {
    
    // Input parameters from the Ballistics model
    private let ballistics: BallisticSettings

    // Weather and environmental conditions
    private let weather: WeatherData
    
    struct WeatherData: Sendable {
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
        guard let point = solveFullTrajectory(upTo: distance).getPoint(at: Measurement(value: distance, unit: UnitLength.meters)) else {
            return .empty
        }

        let baseDropCM = point.drop.converted(to: .centimeters).value
        let baseDropCorrectionMOA = point.dropCorrection.converted(to: .degrees).value * 60.0
        let timeSeconds = point.travelTime.converted(to: .seconds).value
        let baseWindageCM = point.windage.converted(to: .centimeters).value
        let baseWindageCorrectionMOA = point.windageCorrection.converted(to: .degrees).value * 60.0
        let velocityMPS = point.velocity.converted(to: .metersPerSecond).value
        let energyJoules = point.energy.converted(to: .joules).value

        guard ballistics.enableELR && distance > 0 && timeSeconds > 0 else {
            return TrajectoryResult(
                distance: distance,
                dropCM: baseDropCM,
                dropCorrectionMOA: baseDropCorrectionMOA,
                timeSeconds: timeSeconds,
                windageCM: baseWindageCM,
                windageCorrectionMOA: baseWindageCorrectionMOA,
                velocityMPS: velocityMPS,
                energyJoules: energyJoules,
                spinDriftCM: 0,
                spinDriftMOA: 0,
                coriolisHorizontalCM: 0,
                coriolisHorizontalMOA: 0,
                coriolisVerticalCM: 0,
                coriolisVerticalMOA: 0,
                aerodynamicJumpCM: 0,
                aerodynamicJumpMOA: 0,
                totalDropCM: baseDropCM,
                totalDropCorrectionMOA: baseDropCorrectionMOA,
                totalWindageCM: baseWindageCM,
                totalWindageCorrectionMOA: baseWindageCorrectionMOA
            )
        }

        // --- 1. Spin Drift (Bryan Litz / Miller model) ---
        // Drift in inches: 1.25 * (Sg + 1.2) * (t)^1.83. Assuming Sg ~ 1.5 normalized to 10" twist:
        let twistRatio = 10.0 / max(ballistics.twistRateInches, 1.0)
        let directionMultiplier: Double = (ballistics.twistDirection == .right) ? 1.0 : -1.0
        let spinDriftInches = 1.25 * (1.5 + 1.2) * pow(timeSeconds, 1.83) * twistRatio * directionMultiplier
        let spinDriftCM = spinDriftInches * 2.54
        let spinDriftMOA = moaCorrection(fromCM: spinDriftCM, atDistanceMeters: distance)

        // --- 2. Coriolis Effect (Earth's rotation) ---
        // Earth angular velocity Omega = 7.2921159e-5 rad/s
        let omega = 7.2921159e-5
        let latRad = ballistics.latitudeDegrees * .pi / 180.0
        let azimuthRad = ballistics.shootingAzimuthDegrees * .pi / 180.0

        // Horizontal Coriolis (Lateral drift in cm)
        // Deflection = Omega * distance * time * sin(latitude) (meters -> cm)
        let coriolisHorizMeters = omega * distance * timeSeconds * sin(latRad)
        let coriolisHorizontalCM = coriolisHorizMeters * 100.0
        let coriolisHorizontalMOA = moaCorrection(fromCM: coriolisHorizontalCM, atDistanceMeters: distance)

        // Vertical Coriolis / Eötvös Effect (Elevation change in cm)
        // Deflection = 2 * Omega * distance * time * cos(latitude) * sin(azimuth) (meters -> cm)
        let coriolisVertMeters = 2.0 * omega * distance * timeSeconds * cos(latRad) * sin(azimuthRad)
        let coriolisVerticalCM = coriolisVertMeters * 100.0
        let coriolisVerticalMOA = moaCorrection(fromCM: coriolisVerticalCM, atDistanceMeters: distance)

        // --- 3. Aerodynamic Jump ---
        // Crosswind component in m/s
        let windSpeedMPS = weather.windSpeed * (1000.0 / 3600.0)
        let relativeWindAngleRad = (weather.windDirection - ballistics.shootingAzimuthDegrees) * .pi / 180.0
        let crosswindMPS = windSpeedMPS * sin(relativeWindAngleRad)
        // Aerodynamic jump in MOA ~ 0.015 * crosswindMPS * twistRatio * directionMultiplier
        let aeroJumpMOA = 0.015 * crosswindMPS * twistRatio * directionMultiplier
        let aeroJumpCM = cmFromMOA(aeroJumpMOA, atDistanceMeters: distance)

        // --- 4. Total Combined Results ---
        // Eötvös (+ hits higher -> requires less drop correction)
        // Aero jump (+ pushes up -> requires less drop correction)
        let totalDropCM = baseDropCM - coriolisVerticalCM - aeroJumpCM
        let totalDropCorrectionMOA = baseDropCorrectionMOA - coriolisVerticalMOA - aeroJumpMOA

        // Spin drift (+ pushes right)
        // Coriolis (+ pushes right)
        let totalWindageCM = baseWindageCM + spinDriftCM + coriolisHorizontalCM
        let totalWindageCorrectionMOA = baseWindageCorrectionMOA + spinDriftMOA + coriolisHorizontalMOA

        return TrajectoryResult(
            distance: distance,
            dropCM: baseDropCM,
            dropCorrectionMOA: baseDropCorrectionMOA,
            timeSeconds: timeSeconds,
            windageCM: baseWindageCM,
            windageCorrectionMOA: baseWindageCorrectionMOA,
            velocityMPS: velocityMPS,
            energyJoules: energyJoules,
            spinDriftCM: spinDriftCM,
            spinDriftMOA: spinDriftMOA,
            coriolisHorizontalCM: coriolisHorizontalCM,
            coriolisHorizontalMOA: coriolisHorizontalMOA,
            coriolisVerticalCM: coriolisVerticalCM,
            coriolisVerticalMOA: coriolisVerticalMOA,
            aerodynamicJumpCM: aeroJumpCM,
            aerodynamicJumpMOA: aeroJumpMOA,
            totalDropCM: totalDropCM,
            totalDropCorrectionMOA: totalDropCorrectionMOA,
            totalWindageCM: totalWindageCM,
            totalWindageCorrectionMOA: totalWindageCorrectionMOA
        )
    }
    
    private func moaCorrection(fromCM cm: Double, atDistanceMeters dist: Double) -> Double {
        guard dist > 0 else { return 0 }
        // 1 MOA at dist meters is 2.908882 * (dist / 100) cm
        let cmPerMOA = 2.908882 * (dist / 100.0)
        return cm / cmPerMOA
    }

    private func cmFromMOA(_ moa: Double, atDistanceMeters dist: Double) -> Double {
        let cmPerMOA = 2.908882 * (dist / 100.0)
        return moa * cmPerMOA
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
            shootingAngle: Measurement(value: ballistics.inclineAngleDegrees, unit: UnitAngle.degrees),
            zeroRange: Measurement(value: ballistics.zeroRangeMeters, unit: UnitLength.meters),
            atmosphere: Atmosphere(
                altitude: Measurement(value: weather.altitude, unit: UnitLength.meters),
                pressure: Measurement(value: weather.pressure, unit: UnitPressure.hectopascals),
                temperature: Measurement(value: weather.temperature, unit: UnitTemperature.celsius),
                relativeHumidity: weather.humidity
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

    // ELR Settings
    var twistRateInches: Double
    var twistDirection: TwistDirection
    var inclineAngleDegrees: Double
    var shootingAzimuthDegrees: Double
    var latitudeDegrees: Double
    var enableELR: Bool

    init(
        ammunitionName: String,
        ballisticCoefficient: Double,
        calibre: String,
        date: Double,
        distanceMeters: Double,
        dragFunction: Int32,
        id: UUID,
        muzzleEnergy: Double,
        muzzleVelocityMPS: Double,
        projectileManufacturer: String,
        projectileWeightGrains: Double,
        sightHeightCM: Double,
        zeroRangeMeters: Double,
        twistRateInches: Double = 10.0,
        twistDirection: TwistDirection = .right,
        inclineAngleDegrees: Double = 0.0,
        shootingAzimuthDegrees: Double = 0.0,
        latitudeDegrees: Double = 45.0,
        enableELR: Bool = false
    ) {
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
        self.twistRateInches = twistRateInches
        self.twistDirection = twistDirection
        self.inclineAngleDegrees = inclineAngleDegrees
        self.shootingAzimuthDegrees = shootingAzimuthDegrees
        self.latitudeDegrees = latitudeDegrees
        self.enableELR = enableELR
    }
}

