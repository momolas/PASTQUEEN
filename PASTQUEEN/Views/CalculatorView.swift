//
//  SwiftUIView2.swift
//  PASTQUEEN
//
//  Created by Mo on 16/09/2022.
//

import SwiftUI
import SwiftData
import Charts

struct TrajectoryDataPoint: Identifiable {
    let id = UUID()
    let distance: Double
    let drop: Double
}

struct CalculatorView: View {
    let ballisticSettings: Ballistics

    @StateObject private var weatherManager = WeatherManager()
    @StateObject private var locationManager = LocationManager()
    @State private var distance: Double = 100.0
    @State private var trajectoryResult: [Double] = []
    @State private var trajectoryData: [TrajectoryDataPoint] = []

    private func getCalculator() -> BallisticCalculator {
        let weatherData = BallisticCalculator.WeatherData(
            windSpeed: weatherManager.currentWeather?.wind.speed.converted(to: .kilometersPerHour).value ?? 0.0,
            windDirection: weatherManager.currentWeather?.wind.direction.value ?? 0.0,
            pressure: weatherManager.currentWeather?.pressure.converted(to: .hectopascals).value ?? 1013.25,
            temperature: weatherManager.currentWeather?.temperature.converted(to: .celsius).value ?? 15.0,
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

            if !trajectoryResult.isEmpty {
                Section(header: Text("Results for \(distance, specifier: "%.0f") meters")) {
                    HStack {
                        Text("Drop:")
                        Spacer()
                        Text("\(trajectoryResult[1], specifier: "%.2f") cm")
                    }
                    HStack {
                        Text("Drop (MOA):")
                        Spacer()
                        Text("\(trajectoryResult[2], specifier: "%.2f") MOA")
                    }
                    HStack {
                        Text("Windage:")
                        Spacer()
                        Text("\(trajectoryResult[4], specifier: "%.2f") cm")
                    }
                    HStack {
                        Text("Windage (MOA):")
                        Spacer()
                        Text("\(trajectoryResult[5], specifier: "%.2f") MOA")
                    }
                    HStack {
                        Text("Velocity:")
                        Spacer()
                        Text("\(trajectoryResult[6], specifier: "%.0f") m/s")
                    }
                    HStack {
                        Text("Energy:")
                        Spacer()
                        Text("\(trajectoryResult[7], specifier: "%.0f") Joules")
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
    }

    private func calculateTrajectory() {
        let calculator = getCalculator()
        let solution = calculator.solveFullTrajectory(upTo: distance)

        if let point = solution.getPoint(at: Measurement(value: distance, unit: .meters)) {
            trajectoryResult = [
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

        var data: [TrajectoryDataPoint] = []
        for i in stride(from: 0, to: distance, by: 10) {
            if let point = solution.getPoint(at: Measurement(value: i, unit: .meters)) {
                data.append(TrajectoryDataPoint(distance: i, drop: point.drop.converted(to: .centimeters).value))
            }
        }
        trajectoryData = data
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        let container = try! ModelContainer(for: Ballistics.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let sampleBallistics = Ballistics(
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
            projectileWeightGrams: 10.89,
            sightHeightCM: 3.81,
            zeroRangeMeters: 100.0
        )

        return NavigationView {
            CalculatorView(ballisticSettings: sampleBallistics)
        }
        .modelContainer(container)
    }
}
