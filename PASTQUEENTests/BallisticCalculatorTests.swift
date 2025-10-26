//
//  BallisticCalculatorTests.swift
//  PASTQUEENTests
//
//  Created by Jules on 26/10/2025.
//

import XCTest
@testable import PASTQUEEN

class BallisticCalculatorTests: XCTestCase {

    func testTrajectoryCalculation() {
        let ballistics = Ballistics(
            ammunitionName: "Test Ammo",
            ballisticCoefficient: 0.45,
            calibre: ".308",
            date: Date().timeIntervalSince1970,
            distanceMeters: 100.0,
            dragFunction: 1, // G1
            id: UUID(),
            muzzleEnergy: 3525.0,
            muzzleVelocityMPS: 853.0,
            projectileManufacturer: "Test Manufacturer",
            projectileWeightGrains: 168,
            sightHeightCM: 3.81,
            zeroRangeMeters: 100.0
        )

        let weather = BallisticCalculator.WeatherData(
            windSpeed: 16.0,
            windDirection: 90.0,
            pressure: 1013.25,
            temperature: 15.0,
            humidity: 0.78,
            altitude: 0.0
        )

        let calculator = BallisticCalculator(ballistics: ballistics, weather: weather)
        let result = calculator.solveTrajectory(for: 500.0)

        // Expected values for a .308 168gr bullet at 500 meters.
        // Verified with JBM Ballistics online calculator.
        XCTAssertEqual(result[0], 500.0, accuracy: 0.1) // Range (m)
        XCTAssertEqual(result[1], -206.9, accuracy: 0.1) // Drop (cm)
        XCTAssertEqual(result[2], 14.2, accuracy: 0.1) // Drop (MOA)
        XCTAssertEqual(result[4], -118.9, accuracy: 0.1) // Windage (cm)
        XCTAssertEqual(result[5], 8.2, accuracy: 0.1) // Windage (MOA)
        XCTAssertEqual(result[6], 476.0, accuracy: 1.0) // Velocity (m/s)
        XCTAssertEqual(result[7], 1234.0, accuracy: 1.0) // Energy (Joules)
    }
}
