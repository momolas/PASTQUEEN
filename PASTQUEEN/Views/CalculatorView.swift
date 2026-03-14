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

    @Environment(WeatherManager.self) private var weatherManager
    @Environment(LocationManager.self) private var locationManager
    @State private var distance: Double = 100.0
    @State private var trajectoryResult: TrajectoryResult?
    @State private var trajectoryData: [TrajectoryDataPoint] = []
    @State private var selectedDistance: Double?

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
            if let weather = weatherManager.currentWeather {
                Section(header: Text("Weather Used")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Temp")
                            Text(weather.temperature.converted(to: .celsius).value, format: .number.precision(.fractionLength(1)))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Wind")
                            Text(weather.wind.speed.converted(to: .kilometersPerHour).value, format: .number.precision(.fractionLength(1)))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Pressure")
                            Text(weather.pressure.converted(to: .hectopascals).value, format: .number.precision(.fractionLength(0)))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else if let error = weatherManager.errorMessage {
                Section(header: Text("Weather Error")) {
                    Text(error).foregroundStyle(.red)
                }
            }

            Section(header: Text("Input")) {
                TextField("Distance (meters)", value: $distance, format: .number)
                    .keyboardType(.decimalPad)
            }

            Section {
                Button("Calculate") {
                    Task { await calculateTrajectory() }
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
                    Chart(trajectoryData) { point in
                        LineMark(
                            x: .value("Distance", point.distance),
                            y: .value("Drop", point.drop)
                        )
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Distance", point.distance),
                            y: .value("Drop", point.drop)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Gradient(colors: [.blue.opacity(0.3), .blue.opacity(0.0)]))
                        
                        if let selectedDistance, let selectedDrop = trajectoryData.first(where: { abs($0.distance - selectedDistance) < 5.0 })?.drop {
                            RuleMark(x: .value("Distance", selectedDistance))
                                .foregroundStyle(.red)
                                .annotation(position: .top) {
                                    Text("\(selectedDrop, specifier: "%.1f") cm")
                                        .font(.caption)
                                        .padding(4)
                                        .background(.regularMaterial, in: .rect(cornerRadius: 4))
                                }
                        }
                    }
                    .chartXSelection(value: $selectedDistance)
                    .frame(height: 200)
                }
            }
        }
        .navigationTitle("Calculator")
        .onAppear {
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestLocation()
            }
            Task { await calculateTrajectory() }
        }
        .onChange(of: locationManager.location) { _, newLocation in
             if let location = newLocation {
                 Task {
                     await weatherManager.updateCurrentWeather(userLocation: location)
                     await calculateTrajectory()
                 }
             }
        }
    }

    private func calculateTrajectory() async {
        let calculator = getCalculator()
        let result = calculator.solveTrajectory(for: distance)

        let solution = calculator.solveFullTrajectory(upTo: distance)
        let data: [TrajectoryDataPoint] = await Task.detached {
            var dataPoints: [TrajectoryDataPoint] = []
            for i in stride(from: 0, to: distance, by: 10) {
                if let point = solution.getPoint(at: Measurement(value: i, unit: UnitLength.meters)) {
                    dataPoints.append(TrajectoryDataPoint(distance: i, drop: point.drop.converted(to: .centimeters).value))
                }
            }
            return dataPoints
        }.value
        
        await MainActor.run {
            self.trajectoryResult = result
            self.trajectoryData = data
        }
    }
}

#Preview {
    do {
        let container = try ModelContainer(for: BallisticSettings.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
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
                .environment(LocationManager())
                .environment(WeatherManager())
        }
        .modelContainer(container)
    } catch {
        return Text("Failed to create container: \(error.localizedDescription)")
    }
}
