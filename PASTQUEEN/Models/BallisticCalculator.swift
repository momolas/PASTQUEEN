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
        var targetSpeedKMH: Double = 0.0
        var targetAngleDegrees: Double = 90.0
    }
    
    init(ballistics: BallisticSettings, weather: WeatherData) {
        self.ballistics = ballistics
        self.weather = weather
    }
    
    private var effectiveVelocityMPS: Double {
        var v0 = ballistics.muzzleVelocityMPS
        if ballistics.powderSensitivityMPSPerC > 0 {
            let sensitivityFPSPerDegreeF = ballistics.powderSensitivityMPSPerC * 3.28084 / 1.8
            let adj = PowderSensitivity.adjustedVelocity(
                baseVelocity: Measurement(value: ballistics.muzzleVelocityMPS, unit: .metersPerSecond),
                baseTemperature: Measurement(value: 15.0, unit: .celsius),
                currentTemperature: Measurement(value: weather.temperature, unit: .celsius),
                sensitivityFPSPerDegreeF: sensitivityFPSPerDegreeF
            )
            v0 = adj.converted(to: .metersPerSecond).value
        }
        return v0
    }
    
    public func solveTrajectory(for distance: Double) -> TrajectoryResult {
        let solution = solveFullTrajectory(upTo: distance)
        return trajectoryResult(for: distance, from: solution)
    }

    public func trajectoryResult(for distance: Double, from solution: Ballistics) -> TrajectoryResult {
        guard let point = solution.getPoint(at: Measurement(value: distance, unit: UnitLength.meters)) else {
            return .empty
        }

        let baseDropCM = point.drop.converted(to: .centimeters).value
        let baseDropCorrectionMOA = point.dropCorrection.converted(to: .degrees).value * 60.0
        let timeSeconds = point.travelTime.converted(to: .seconds).value
        let baseWindageCM = point.windage.converted(to: .centimeters).value
        let baseWindageCorrectionMOA = point.windageCorrection.converted(to: .degrees).value * 60.0
        let velocityMPS = point.velocity.converted(to: .metersPerSecond).value
        let energyJoules = point.energy.converted(to: .joules).value

        // --- Moving Target Lead ---
        let targetSpeedMPS = weather.targetSpeedKMH / 3.6
        let crossTargetSpeedMPS = targetSpeedMPS * sin(weather.targetAngleDegrees * .pi / 180.0)
        let leadMeters = crossTargetSpeedMPS * timeSeconds
        let leadCM = leadMeters * 100.0
        let leadMOA = moaCorrection(fromCM: leadCM, atDistanceMeters: distance)

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
                movingTargetLeadCM: leadCM,
                movingTargetLeadMOA: leadMOA,
                totalDropCM: baseDropCM,
                totalDropCorrectionMOA: baseDropCorrectionMOA,
                totalWindageCM: baseWindageCM + leadCM,
                totalWindageCorrectionMOA: baseWindageCorrectionMOA + leadMOA
            )
        }

        // --- 1. Spin Drift (from Ballistics 3-DOF solver) ---
        let spinDriftCM = point.spinDrift?.converted(to: .centimeters).value ?? 0.0
        let spinDriftMOA = moaCorrection(fromCM: spinDriftCM, atDistanceMeters: distance)

        // --- 2. Coriolis Effect (from Ballistics 3-DOF solver) ---
        let coriolisHorizontalCM = point.coriolisHorizontal?.converted(to: .centimeters).value ?? 0.0
        let coriolisHorizontalMOA = moaCorrection(fromCM: coriolisHorizontalCM, atDistanceMeters: distance)

        let coriolisVerticalCM = point.coriolisVertical?.converted(to: .centimeters).value ?? 0.0
        let coriolisVerticalMOA = moaCorrection(fromCM: coriolisVerticalCM, atDistanceMeters: distance)

        // --- 3. Aerodynamic Jump (via AerodynamicJump utility) ---
        let relativeWindAngleRad = (weather.windDirection - ballistics.shootingAzimuthDegrees) * .pi / 180.0
        let windSpeedMPS = Measurement(value: weather.windSpeed, unit: UnitSpeed.kilometersPerHour).converted(to: .metersPerSecond).value
        let crosswindMPS = windSpeedMPS * sin(relativeWindAngleRad)
        let aeroJumpAngle = AerodynamicJump.jumpAngle(
            crosswindSpeed: Measurement(value: crosswindMPS, unit: .metersPerSecond),
            initialVelocity: Measurement(value: effectiveVelocityMPS, unit: .metersPerSecond),
            twistDirection: ballistics.twistDirection
        )
        let aeroJumpMOA = aeroJumpAngle.converted(to: .minutesOfAngle).value
        let aeroJumpCM = cmFromMOA(aeroJumpMOA, atDistanceMeters: distance)

        // --- 4. Total Combined Results ---
        let totalDropCM = baseDropCM - coriolisVerticalCM - aeroJumpCM
        let totalDropCorrectionMOA = baseDropCorrectionMOA - coriolisVerticalMOA - aeroJumpMOA

        let totalWindageCM = baseWindageCM + spinDriftCM + coriolisHorizontalCM + leadCM
        let totalWindageCorrectionMOA = baseWindageCorrectionMOA + spinDriftMOA + coriolisHorizontalMOA + leadMOA

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
            movingTargetLeadCM: leadCM,
            movingTargetLeadMOA: leadMOA,
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
        let dragFunc: DragFunction
        switch ballistics.dragFunction {
        case 7: dragFunc = .g7
        case 2: dragFunc = .g2
        case 5: dragFunc = .g5
        case 6: dragFunc = .g6
        case 8: dragFunc = .g8
        default: dragFunc = .g1
        }

        let effectiveV0 = effectiveVelocityMPS
        let twistMeasurement: Measurement<UnitLength>? = ballistics.enableELR
            ? Measurement(value: ballistics.twistRateInches, unit: .inches)
            : nil
        let latitudeMeasurement: Measurement<UnitAngle>? = ballistics.enableELR
            ? Measurement(value: ballistics.latitudeDegrees, unit: .degrees)
            : nil
        let azimuthMeasurement: Measurement<UnitAngle>? = ballistics.enableELR
            ? Measurement(value: ballistics.shootingAzimuthDegrees, unit: .degrees)
            : nil

        return Ballistics.solve3DOF(
            preferredDistanceUnit: .meters,
            dragFunction: dragFunc,
            dragCoefficient: ballistics.ballisticCoefficient,
            initialVelocity: Measurement(value: effectiveV0, unit: UnitSpeed.metersPerSecond),
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
            weight: Measurement(value: ballistics.projectileWeightGrains, unit: UnitMass.grains),
            twist: twistMeasurement,
            twistDirection: ballistics.twistDirection,
            latitude: latitudeMeasurement,
            azimuth: azimuthMeasurement
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
    var powderSensitivityMPSPerC: Double = 0.0


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
        powderSensitivityMPSPerC: Double = 0.0,
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
        self.powderSensitivityMPSPerC = powderSensitivityMPSPerC
        self.twistRateInches = twistRateInches
        self.twistDirection = twistDirection
        self.inclineAngleDegrees = inclineAngleDegrees
        self.shootingAzimuthDegrees = shootingAzimuthDegrees
        self.latitudeDegrees = latitudeDegrees
        self.enableELR = enableELR
    }
}


