//
//  CalculatorView.swift
//  PASTQUEEN
//
//  Created by Mo on 16/09/2022.
//

import SwiftUI
import SwiftData
import Charts
import CoreLocation

struct TrajectoryDataPoint: Identifiable {
    let id = UUID()
    let distance: Double
    let drop: Double
}

struct CalculatorView: View {
    let ballisticSettings: BallisticSettings

    @State private var weatherManager = WeatherManager()
    @State private var locationManager = LocationManager()
    @State private var distance: Double = 100.0
    @State private var trajectoryResult: TrajectoryResult?
    @State private var trajectoryData: [TrajectoryDataPoint] = []

    private func getCalculator() -> BallisticCalculator {
        let weatherData = BallisticCalculator.WeatherData(
            windSpeed: weatherManager.currentWeather?.wind.speed.converted(to: UnitSpeed.kilometersPerHour).value ?? 0.0,
            windDirection: weatherManager.currentWeather?.wind.direction.value ?? 0.0,
            pressure: weatherManager.currentWeather?.pressure.converted(to: UnitPressure.hectopascals).value ?? 1013.25,
            temperature: weatherManager.currentWeather?.temperature.converted(to: UnitTemperature.celsius).value ?? 15.0,
            humidity: weatherManager.currentWeather?.humidity ?? 0.78,
            altitude: locationManager.altitude ?? 0.0
        )
        return BallisticCalculator(ballistics: ballisticSettings, weather: weatherData)
    }

    var body: some View {
        Form {
            Section(header: Text("Input")) {
                TextField("Distance (meters)", value: $distance, format: .number)
                    .keyboardType(.decimalPad)
            }

            Section {
                Button("Calculate") {
                    calculateTrajectory()
                }
            }

            if let result = trajectoryResult {
                Section(header: Text("Results for \(distance, specifier: "%.0f") meters")) {
                    HStack {
                        Text("Drop:")
                        Spacer()
                        Text("\(result.dropCM, specifier: "%.2f") cm")
                    }
                    HStack {
                        Text("Drop (MOA):")
                        Spacer()
                        Text("\(result.dropCorrectionMOA, specifier: "%.2f") MOA")
                    }
                    HStack {
                        Text("Windage:")
                        Spacer()
                        Text("\(result.windageCM, specifier: "%.2f") cm")
                    }
                    HStack {
                        Text("Windage (MOA):")
                        Spacer()
                        Text("\(result.windageCorrectionMOA, specifier: "%.2f") MOA")
                    }
                    HStack {
                        Text("Velocity:")
                        Spacer()
                        Text("\(result.velocityMPS, specifier: "%.0f") m/s")
                    }
                    HStack {
                        Text("Energy:")
                        Spacer()
                        Text("\(result.energyJoules, specifier: "%.0f") Joules")
                    }
                }
            }

            if !trajectoryData.isEmpty {
                Section(header: Text("Trajectory")) {
                    Chart(trajectoryData) {
                        LineMark(
                            x: .value("Distance", $0.distance),
                            y: .value("Drop", $0.drop)
                        )
                    }
                    .frame(height: 200)
                }
            }
        }
        .navigationTitle("Calculator")
        .onAppear {
            locationManager.requestLocation()
            calculateTrajectory()
        }
        .onChange(of: locationManager.location) { _, newLocation in
             if let location = newLocation {
                 Task {
                     await weatherManager.updateCurrentWeather(userLocation: location)
                 }
             }
        }
    }

    private func calculateTrajectory() {
        let calculator = getCalculator()
        trajectoryResult = calculator.solveTrajectory(for: distance)

        let solution = calculator.solveFullTrajectory(upTo: distance)
        var data: [TrajectoryDataPoint] = []
        for i in stride(from: 0, to: distance, by: 10) {
            if let point = solution.getPoint(at: Measurement(value: i, unit: UnitLength.meters)) {
                data.append(TrajectoryDataPoint(distance: i, drop: point.drop.converted(to: UnitLength.centimeters).value))
            }
        }
        trajectoryData = data
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        let container = try! ModelContainer(for: BallisticSettings.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let sampleBallistics = BallisticSettings(
            ammunitionName: "Preview Ammo",
            ballisticCoefficient: 0.45,
            calibre: ".308",
            date: Date().timeIntervalSince1970,
            distanceMeters: 100.0,
            dragFunction: 1,
            id: UUID(),
            muzzleEnergy: 3525.0,
            muzzleVelocityMPS: 853.0,
            projectileManufacturer: "Preview Manufacturer",
            projectileWeightGrains: 168.0,
            sightHeightCM: 3.81,
            zeroRangeMeters: 100.0
        )

        return NavigationStack {
            CalculatorView(ballisticSettings: sampleBallistics)
        }
        .modelContainer(container)
    }
}
