//
//  CalculatorView.swift
//  PASTQUEEN
//

import SwiftUI
import SwiftData
import Charts
import CoreLocation

struct CalculatorView: View {
    let weapon: Weapon

    @Environment(\.weatherService) private var weatherManager
    @Environment(\.locationService) private var locationManager
    
    @State private var selectedAmmunition: Ammunition?
    @State private var distance: Double = 100.0
    @State private var trajectoryResult: TrajectoryResult?
    @State private var trajectoryData: [TrajectoryDataPoint] = []
    @State private var selectedDistance: Double?
    @State private var calculationTask: Task<Void, Never>?

    private func getCalculator() -> BallisticCalculator {
        let weatherData = BallisticCalculator.WeatherData(
            windSpeed: weatherManager?.currentWeather?.wind.speed.converted(to: UnitSpeed.kilometersPerHour).value ?? 0.0,
            windDirection: weatherManager?.currentWeather?.wind.direction.value ?? 0.0,
            pressure: weatherManager?.currentWeather?.pressure.converted(to: UnitPressure.hectopascals).value ?? 1013.25,
            temperature: weatherManager?.currentWeather?.temperature.converted(to: UnitTemperature.celsius).value ?? 15.0,
            humidity: weatherManager?.currentWeather?.humidity ?? 0.78,
            altitude: locationManager?.altitude ?? 0.0
        )
        
        let settings = BallisticSettings(
            ammunitionName: selectedAmmunition?.name ?? "Default",
            ballisticCoefficient: selectedAmmunition?.ballisticCoefficient ?? 0.45,
            calibre: weapon.calibre,
            date: selectedAmmunition?.date ?? Date().timeIntervalSince1970,
            distanceMeters: distance,
            dragFunction: selectedAmmunition?.dragFunction ?? 1,
            id: selectedAmmunition?.id ?? UUID(),
            muzzleEnergy: selectedAmmunition?.muzzleEnergy ?? 3500.0,
            muzzleVelocityMPS: selectedAmmunition?.muzzleVelocityMPS ?? 800.0,
            projectileManufacturer: selectedAmmunition?.projectileManufacturer ?? "Default",
            projectileWeightGrains: selectedAmmunition?.projectileWeightGrains ?? 168.0,
            sightHeightCM: weapon.sightHeightCM,
            zeroRangeMeters: weapon.zeroRangeMeters
        )
        
        return BallisticCalculator(ballistics: settings, weather: weatherData)
    }

    var body: some View {
        Form {
            Section(header: Text("Rifle & Setup")) {
                LabeledContent("Rifle", value: weapon.name)
                LabeledContent(String(localized: .caliber), value: weapon.calibre)
                LabeledContent("Sight Height", value: "\(weapon.sightHeightCM.formatted()) cm")
                LabeledContent("Zero Range", value: "\(weapon.zeroRangeMeters.formatted()) m")
            }

            Section(header: Text("Ammunition Load")) {
                let ammoList = weapon.ammunitions?.sorted(by: { $0.date > $1.date }) ?? []
                if ammoList.isEmpty {
                    NavigationLink(destination: AddAmmunitionView(weapon: weapon)) {
                        Label("Add Ammunition Load", systemImage: "plus.circle")
                            .bold()
                            .foregroundStyle(.blue)
                    }
                } else {
                    Picker("Selected Load", selection: $selectedAmmunition) {
                        ForEach(ammoList) { ammo in
                            Text(ammo.name).tag(ammo as Ammunition?)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    NavigationLink(destination: AddAmmunitionView(weapon: weapon)) {
                        Label("Add New Load", systemImage: "plus.circle")
                            .foregroundStyle(.blue)
                    }
                }
            }

            if let weather = weatherManager?.currentWeather {
                Section(header: HStack {
                    Text(.weatherUsed)
                    Spacer()
                    Button("Refresh weather", systemImage: "arrow.clockwise", action: refreshWeather)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(.temp)
                            Text(weather.temperature.converted(to: .celsius).value, format: .number.precision(.fractionLength(1)))
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(.wind)
                            Text(weather.wind.speed.converted(to: .kilometersPerHour).value, format: .number.precision(.fractionLength(1)))
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(.pressure)
                            Text(weather.pressure.converted(to: .hectopascals).value, format: .number.precision(.fractionLength(0)))
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else if let error = weatherManager?.errorMessage {
                Section(header: HStack {
                    Text(.weatherError)
                    Spacer()
                    Button("Refresh weather", systemImage: "arrow.clockwise", action: refreshWeather)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                }) {
                    Text(error).foregroundStyle(.red)
                }
            } else {
                Section(header: HStack {
                    Text(.weather)
                    Spacer()
                    Button("Refresh weather", systemImage: "arrow.clockwise", action: refreshWeather)
                    .labelStyle(.iconOnly)
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
                Button(.calculate, action: triggerCalculation)
            }

            if let result = trajectoryResult {
                Section(header: Text("Results for \(Int(distance)) meters")) {
                    HStack {
                        Text(.drop)
                        Spacer()
                        Text("\(result.dropCM, format: .number.precision(.fractionLength(2))) cm")
                            .fontDesign(.rounded)
                    }
                    HStack {
                        Text(.dropMOA)
                        Spacer()
                        Text("\(result.dropCorrectionMOA, format: .number.precision(.fractionLength(2))) MOA")
                            .fontDesign(.rounded)
                    }
                    HStack {
                        Text(.windage)
                        Spacer()
                        Text("\(result.windageCM, format: .number.precision(.fractionLength(2))) cm")
                            .fontDesign(.rounded)
                    }
                    HStack {
                        Text(.windageMOA)
                        Spacer()
                        Text("\(result.windageCorrectionMOA, format: .number.precision(.fractionLength(2))) MOA")
                            .fontDesign(.rounded)
                    }
                    HStack {
                        Text(.velocity)
                        Spacer()
                        Text("\(result.velocityMPS, format: .number.precision(.fractionLength(0))) m/s")
                            .fontDesign(.rounded)
                    }
                    HStack {
                        Text(.energy)
                        Spacer()
                        Text("\(result.energyJoules, format: .number.precision(.fractionLength(0))) Joules")
                            .fontDesign(.rounded)
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
                                    Text("\(selectedDrop, format: .number.precision(.fractionLength(1))) cm")
                                        .font(.caption)
                                        .fontDesign(.rounded)
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
        .task {
            if locationManager?.authorizationStatus == .notDetermined {
                locationManager?.requestLocation()
            }
            setupDefaultAmmunition()
            await calculateTrajectory()
        }
        .onChange(of: weapon) { _, _ in
            setupDefaultAmmunition()
            triggerCalculation()
        }
        .onChange(of: weapon.ammunitions) { _, _ in
            setupDefaultAmmunition()
            triggerCalculation()
        }
        .onChange(of: selectedAmmunition) { _, _ in
            triggerCalculation()
        }
        .onChange(of: locationManager?.location) { _, _ in
             triggerCalculation()
        }
    }

    private func setupDefaultAmmunition() {
        let ammoList = weapon.ammunitions?.sorted(by: { $0.date > $1.date }) ?? []
        if selectedAmmunition == nil || !ammoList.contains(where: { $0.id == selectedAmmunition?.id }) {
            selectedAmmunition = ammoList.first
        }
    }

    @MainActor
    private func refreshWeather() {
        guard let loc = locationManager?.location else {
            locationManager?.requestLocation()
            return
        }
        calculationTask?.cancel()
        calculationTask = Task {
            await weatherManager?.updateCurrentWeather(userLocation: loc)
            await calculateTrajectory()
        }
    }

    @MainActor
    private func triggerCalculation() {
        calculationTask?.cancel()
        calculationTask = Task {
            await calculateTrajectory()
        }
    }

    @MainActor
    private func calculateTrajectory() async {
        let calculator = getCalculator()
        let result = calculator.solveTrajectory(for: distance)

        let solution = calculator.solveFullTrajectory(upTo: distance)
        let currentDistance = distance
        let data: [TrajectoryDataPoint] = await Task.detached {
            var dataPoints: [TrajectoryDataPoint] = []
            for i in stride(from: 0, to: currentDistance, by: 10) {
                if Task.isCancelled { break }
                if let point = solution.getPoint(at: Measurement(value: i, unit: UnitLength.meters)) {
                    dataPoints.append(TrajectoryDataPoint(distance: i, drop: point.drop.converted(to: .centimeters).value))
                }
            }
            return dataPoints
        }.value
        
        guard !Task.isCancelled else { return }
        
        self.trajectoryResult = result
        self.trajectoryData = data
    }
}

#Preview {
    let sampleWeapon = Weapon(name: "Preview Rifle", calibre: ".308", sightHeightCM: 4.5, zeroRangeMeters: 100.0)
    NavigationStack {
        CalculatorView(weapon: sampleWeapon)
            .environment(\.locationService, LocationManager())
            .environment(\.weatherService, WeatherManager())
    }
    .modelContainer(for: Weapon.self, inMemory: true)
}
