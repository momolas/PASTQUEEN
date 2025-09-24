//
//  SwiftUIView2.swift
//  PASTQUEEN
//
//  Created by Mo on 16/09/2022.
//

import SwiftUI
import SwiftData

struct CalculatorView: View {
    let ballisticSettings: Ballistics

    @StateObject private var weatherManager = WeatherManager()
    @State private var distance: Double = 100.0
    @State private var trajectoryResult: [Double] = []

    private func getCalculator() -> BallisticCalculator {
        let weatherData = BallisticCalculator.WeatherData(
            windSpeed: weatherManager.currentWeather?.wind.speed.converted(to: .milesPerHour).value ?? 0.0,
            windDirection: weatherManager.currentWeather?.wind.direction.value ?? 0.0,
            pressure: weatherManager.currentWeather?.pressure.converted(to: .inchesOfMercury).value ?? 29.53,
            temperatureF: weatherManager.currentWeather?.temperature.converted(to: .fahrenheit).value ?? 59.0,
            humidity: weatherManager.currentWeather?.humidity ?? 0.78,
            altitude: 0.0 // Altitude should be sourced from LocationManager
        )
        return BallisticCalculator(ballistics: ballisticSettings, weather: weatherData)
    }

    var body: some View {
        Form {
            Section(header: Text("Input")) {
                TextField("Distance (yards)", value: $distance, format: .number)
                    .keyboardType(.decimalPad)
            }

            Section {
                Button("Calculate") {
                    calculateTrajectory()
                }
            }

            if !trajectoryResult.isEmpty {
                Section(header: Text("Results for \(distance, specifier: "%.0f") yards")) {
                    HStack {
                        Text("Drop:")
                        Spacer()
                        Text("\(trajectoryResult[1], specifier: "%.2f") inches")
                    }
                    HStack {
                        Text("Drop (MOA):")
                        Spacer()
                        Text("\(trajectoryResult[2], specifier: "%.2f") MOA")
                    }
                    HStack {
                        Text("Windage:")
                        Spacer()
                        Text("\(trajectoryResult[4], specifier: "%.2f") inches")
                    }
                    HStack {
                        Text("Windage (MOA):")
                        Spacer()
                        Text("\(trajectoryResult[5], specifier: "%.2f") MOA")
                    }
                    HStack {
                        Text("Velocity:")
                        Spacer()
                        Text("\(trajectoryResult[6], specifier: "%.0f") ft/s")
                    }
                    HStack {
                        Text("Energy:")
                        Spacer()
                        Text("\(trajectoryResult[7], specifier: "%.0f") ft-lbs")
                    }
                }
            }
        }
        .navigationTitle("Calculator")
        .onAppear {
            calculateTrajectory()
        }
    }

    private func calculateTrajectory() {
        let calculator = getCalculator()
        trajectoryResult = calculator.solveTrajectory(for: distance)
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
            distanceYards: 100.0,
            dragFunction: 1,
            id: UUID(),
            muzzleEnergy: 2600.0,
            muzzleVelocity: 2800.0,
            projectileManufacturer: "Preview Manufacturer",
            projectileWeight: 168,
            sightHeight: 1.5,
            zeroRange: 100.0
        )

        return NavigationView {
            CalculatorView(ballisticSettings: sampleBallistics)
        }
        .modelContainer(container)
    }
}