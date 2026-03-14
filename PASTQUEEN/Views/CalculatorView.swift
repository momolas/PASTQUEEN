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
                Section(header: HStack {
                    Text(.weatherUsed)
                    Spacer()
                    Button {
                        if let loc = locationManager.location {
                             Task {
                                 await weatherManager.updateCurrentWeather(userLocation: loc)
                                 await calculateTrajectory()
                             }
                        } else {
                             locationManager.requestLocation()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(.temp)
                            Text(weather.temperature.converted(to: .celsius).value, format: .number.precision(.fractionLength(1)))
                                .fontDesign(.rounded)
                                .fontWeight(.light)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(.wind)
                            Text(weather.wind.speed.converted(to: .kilometersPerHour).value, format: .number.precision(.fractionLength(1)))
                                .fontDesign(.rounded)
                                .fontWeight(.light)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(.pressure)
                            Text(weather.pressure.converted(to: .hectopascals).value, format: .number.precision(.fractionLength(0)))
                                .fontDesign(.rounded)
                                .fontWeight(.light)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else if let error = weatherManager.errorMessage {
                Section(header: HStack {
                    Text(.weatherError)
                    Spacer()
                    Button {
                        if let loc = locationManager.location {
                             Task {
                                 await weatherManager.updateCurrentWeather(userLocation: loc)
                                 await calculateTrajectory()
                             }
                        } else {
                             locationManager.requestLocation()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                }) {
                    Text(error).foregroundStyle(.red)
                }
            } else {
                Section(header: HStack {
                    Text(.weather)
                    Spacer()
                    Button {
                        if let loc = locationManager.location {
                             Task {
                                 await weatherManager.updateCurrentWeather(userLocation: loc)
                                 await calculateTrajectory()
                             }
                        } else {
                             locationManager.requestLocation()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                }) {
                    Text(.pressRefreshWeather)
                        .foregroundStyle(.secondary)
                }
            }

            Section(header: Text(String(localized: .input))) {
                TextField(String(localized: .distanceMeters), value: $distance, format: .number)
                    .keyboardType(.decimalPad)
            }

            Section {
                Button(.calculate) {
                    Task { await calculateTrajectory() }
                }
            }

            if let result = trajectoryResult {
                Section(header: Text("Results for \(distance, specifier: "%.0f") meters")) {
                    HStack {
                        Text(.drop)
                        Spacer()
                        Text("\(result.dropCM, specifier: "%.2f") cm")
                            .fontDesign(.rounded)
                            .fontWeight(.light)
                    }
                    HStack {
                        Text(.dropMOA)
                        Spacer()
                        Text("\(result.dropCorrectionMOA, specifier: "%.2f") MOA")
                            .fontDesign(.rounded)
                            .fontWeight(.light)
                    }
                    HStack {
                        Text(.windage)
                        Spacer()
                        Text("\(result.windageCM, specifier: "%.2f") cm")
                            .fontDesign(.rounded)
                            .fontWeight(.light)
                    }
                    HStack {
                        Text(.windageMOA)
                        Spacer()
                        Text("\(result.windageCorrectionMOA, specifier: "%.2f") MOA")
                            .fontDesign(.rounded)
                            .fontWeight(.light)
                    }
                    HStack {
                        Text(.velocity)
                        Spacer()
                        Text("\(result.velocityMPS, specifier: "%.0f") m/s")
                            .fontDesign(.rounded)
                            .fontWeight(.light)
                    }
                    HStack {
                        Text(.energy)
                        Spacer()
                        Text("\(result.energyJoules, specifier: "%.0f") Joules")
                            .fontDesign(.rounded)
                            .fontWeight(.light)
                    }
                }
            }

            if !trajectoryData.isEmpty {
                Section(header: Text(String(localized: .trajectory))) {
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
                                        .fontDesign(.rounded)
                                        .fontWeight(.light)
                                        .padding(4)
                                        .background(.thinMaterial, in: .rect(cornerRadius: 10))
                                }
                        }
                    }
                    .chartXSelection(value: $selectedDistance)
                    .frame(height: 200)
                }
            }
        }
        .navigationTitle(String(localized: .calculator))
        .onAppear {
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestLocation()
            }
            Task { await calculateTrajectory() }
        }
        .onChange(of: locationManager.location) { _, _ in
             Task { await calculateTrajectory() }
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
