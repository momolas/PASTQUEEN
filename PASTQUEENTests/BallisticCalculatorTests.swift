//
//  BallisticCalculatorTests.swift
//  PASTQUEENTests
//
//  Created by Jules on 26/10/2025.
//

import XCTest
@testable import PASTQUEEN

final class BallisticCalculatorTests: XCTestCase {

    func testTrajectoryCalculation() {
        let settings = BallisticSettings(
            ammunitionName: "Test",
            ballisticCoefficient: 0.5,
            calibre: ".308",
            date: Date().timeIntervalSince1970,
            distanceMeters: 100,
            dragFunction: 1, // G1
            id: UUID(),
            muzzleEnergy: 3000,
            muzzleVelocityMPS: 800,
            projectileManufacturer: "Test",
            projectileWeightGrains: 150,
            sightHeightCM: 4,
            zeroRangeMeters: 100
        )

        let weather = BallisticCalculator.WeatherData(
            windSpeed: 0,
            windDirection: 0,
            pressure: 1013.25,
            temperature: 15,
            humidity: 0.5,
            altitude: 0
        )

        let calculator = BallisticCalculator(ballistics: settings, weather: weather)

        let result = calculator.solveTrajectory(for: 200) // Calculate for 200m

        XCTAssertEqual(result.distance, 200)
        XCTAssertGreaterThan(result.velocityMPS, 0)
        XCTAssertGreaterThan(result.energyJoules, 0)
        XCTAssertLessThan(result.velocityMPS, 800) // Should slow down

        // Check drop is present (positive or negative depending on convention, usually drop is positive down)
        // Library specific, but we check it's not 0 generally unless it's strictly flat (impossible)
        XCTAssertNotEqual(result.dropCM, 0)
    }
}
