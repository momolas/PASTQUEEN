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
    @Environment(\.sensorService) private var sensorManager
    
    @State private var selectedAmmunition: Ammunition?
    @State private var distance: Double = 100.0
    @State private var trajectoryResult: TrajectoryResult?
    @State private var trajectoryData: [TrajectoryDataPoint] = []
    @State private var selectedDistance: Double?
    @State private var calculationTask: Task<Void, Never>?

    @State private var useOfflineSensors = false
    @State private var manualWindSpeed: Double = 0.0
    @State private var windDirectionDegrees: Double = 0.0

    // ELR State
    @State private var enableELR = false
    @State private var inclineAngleDegrees: Double = 0.0
    @State private var shootingAzimuthDegrees: Double = 0.0
    @State private var liveCompassActive = false
    @State private var liveInclinometerActive = false

    private func getCalculator() -> BallisticCalculator {
        let localPressure = (useOfflineSensors && sensorManager?.currentPressureHPa != nil)
            ? sensorManager!.currentPressureHPa!
            : weatherManager?.currentWeather?.pressure.converted(to: UnitPressure.hectopascals).value ?? 1013.25

        let weatherData = BallisticCalculator.WeatherData(
            windSpeed: manualWindSpeed,
            windDirection: windDirectionDegrees,
            pressure: localPressure,
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
            zeroRangeMeters: weapon.zeroRangeMeters,
            twistRateInches: weapon.twistRateInches,
            twistDirection: weapon.twistDirection,
            inclineAngleDegrees: inclineAngleDegrees,
            shootingAzimuthDegrees: shootingAzimuthDegrees,
            latitudeDegrees: locationManager?.latitude ?? 45.0,
            enableELR: enableELR
        )
        
        return BallisticCalculator(ballistics: settings, weather: weatherData)
    }

    var body: some View {
        Form {
            Section(header: Text(.rifleSetup)) {
                LabeledContent(String(localized: .rifle), value: weapon.name)
                LabeledContent(String(localized: .caliber), value: weapon.calibre)
                LabeledContent(String(localized: .sightHeight), value: "\(weapon.sightHeightCM.formatted()) cm")
                LabeledContent(String(localized: .zeroRangeLabel), value: "\(weapon.zeroRangeMeters.formatted()) m")
                LabeledContent("Pas de rayure", value: "1:\(weapon.twistRateInches.formatted()) (\(weapon.twistDirection.rawValue))")
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
                    Toggle(isOn: $useOfflineSensors) {
                        Label("Offline Barometer", systemImage: "sensor")
                    }
                    .onChange(of: useOfflineSensors) { _, newValue in
                        if newValue {
                            sensorManager?.startMonitoring()
                        } else {
                            sensorManager?.stopMonitoring()
                        }
                        triggerCalculation()
                    }
                    
                    if useOfflineSensors {
                        LabeledContent("Local Pressure", value: "\(sensorManager?.currentPressureHPa?.formatted(.number.precision(.fractionLength(1))) ?? "Reading...") hPa")
                    }
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

            Section(header: Text("Wind Conditions")) {
                HStack {
                    Text("Wind Speed (km/h)")
                    Spacer()
                    TextField("Speed", value: $manualWindSpeed, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                
                WindClockPicker(windDirectionDegrees: $windDirectionDegrees)
            }

            // Advanced ELR Module Section
            Section(header: Label("Très Longue Distance (ELR)", systemImage: "scope")) {
                Toggle(isOn: $enableELR) {
                    Text("Activer les effets ELR")
                        .bold()
                }
                
                if enableELR {
                    // Incline Angle / Inclinometer
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Angle de tir / Pente")
                            Spacer()
                            TextField("Angle", value: $inclineAngleDegrees, format: .number.precision(.fractionLength(1)))
                                .keyboardType(.numbersAndPunctuation)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 70)
                            Text("°")
                        }
                        
                        Button {
                            liveInclinometerActive.toggle()
                            if liveInclinometerActive {
                                sensorManager?.startInclineMonitoring()
                            } else {
                                sensorManager?.stopInclineMonitoring()
                            }
                        } label: {
                            Label(
                                liveInclinometerActive ? "Inclinomètre Actif (posé sur le canon)" : "Mesurer l'angle (Capteur)",
                                systemImage: liveInclinometerActive ? "level.fill" : "level"
                            )
                            .font(.caption)
                            .foregroundStyle(liveInclinometerActive ? .green : .blue)
                        }
                        .buttonStyle(.borderless)
                    }

                    // Shooting Azimuth / Compass
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Azimut de tir (Cap)")
                            Spacer()
                            TextField("Azimut", value: $shootingAzimuthDegrees, format: .number.precision(.fractionLength(0)))
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 70)
                            Text("°")
                        }
                        
                        Button {
                            liveCompassActive.toggle()
                            if liveCompassActive {
                                locationManager?.startUpdatingHeading()
                            } else {
                                locationManager?.stopUpdatingHeading()
                            }
                        } label: {
                            Label(
                                liveCompassActive ? "Boussole Active (viser la cible)" : "Capturer le cap (Boussole)",
                                systemImage: liveCompassActive ? "location.north.line.fill" : "safari"
                            )
                            .font(.caption)
                            .foregroundStyle(liveCompassActive ? .green : .blue)
                        }
                        .buttonStyle(.borderless)
                    }

                    if let lat = locationManager?.latitude {
                        LabeledContent("Latitude actuelle", value: "\(lat.formatted(.number.precision(.fractionLength(2))))°")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Button(.calculate, action: triggerCalculation)
            }

            if let result = trajectoryResult {
                Section(header: Text("Results for \(Int(distance)) meters")) {
                    HStack {
                        Text(.drop)
                        Spacer()
                        Text("\(result.totalDropCM, format: .number.precision(.fractionLength(2))) cm")
                            .fontDesign(.rounded)
                    }
                    HStack {
                        Text(.dropMOA)
                        Spacer()
                        Text("\(result.totalDropCorrectionMOA, format: .number.precision(.fractionLength(2))) MOA")
                            .fontDesign(.rounded)
                    }
                    
                    let dropClicks = weapon.scopeClickUnit.clicks(forMOACorrection: result.totalDropCorrectionMOA)
                    let dropDirectionKey: LocalizedStringResource = result.totalDropCorrectionMOA >= 0 ? .up : .down
                    HStack {
                        Text(.elevationAdjustment)
                        Spacer()
                        Text("\(dropClicks) \(Text(.clicks)) (\(Text(dropDirectionKey).bold().foregroundStyle(.blue)))")
                    }
                    .fontDesign(.rounded)
                    
                    HStack {
                        Text(.windage)
                        Spacer()
                        Text("\(result.totalWindageCM, format: .number.precision(.fractionLength(2))) cm")
                            .fontDesign(.rounded)
                    }
                    HStack {
                        Text(.windageMOA)
                        Spacer()
                        Text("\(result.totalWindageCorrectionMOA, format: .number.precision(.fractionLength(2))) MOA")
                            .fontDesign(.rounded)
                    }
                    
                    let windageClicks = weapon.scopeClickUnit.clicks(forMOACorrection: result.totalWindageCorrectionMOA)
                    let windageDirectionKey: LocalizedStringResource = result.totalWindageCorrectionMOA >= 0 ? .right : .left
                    HStack {
                        Text(.windageAdjustment)
                        Spacer()
                        Text("\(windageClicks) \(Text(.clicks)) (\(Text(windageDirectionKey).bold().foregroundStyle(.blue)))")
                    }
                    .fontDesign(.rounded)
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
                    HStack {
                        Text("Temps de vol")
                        Spacer()
                        Text("\(result.timeSeconds, format: .number.precision(.fractionLength(2))) s")
                            .fontDesign(.rounded)
                    }
                }

                if enableELR {
                    Section(header: Text("Décomposition des Effets ELR")) {
                        HStack {
                            Text("Dérive Gyroscopique (Spin Drift)")
                            Spacer()
                            Text("\(result.spinDriftCM, format: .number.precision(.fractionLength(1))) cm (\(result.spinDriftMOA, format: .number.precision(.fractionLength(2))) MOA)")
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Coriolis Horizontal")
                            Spacer()
                            Text("\(result.coriolisHorizontalCM, format: .number.precision(.fractionLength(1))) cm (\(result.coriolisHorizontalMOA, format: .number.precision(.fractionLength(2))) MOA)")
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Coriolis Vertical (Eötvös)")
                            Spacer()
                            Text("\(result.coriolisVerticalCM, format: .number.precision(.fractionLength(1))) cm (\(result.coriolisVerticalMOA, format: .number.precision(.fractionLength(2))) MOA)")
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Saut Aérodynamique (Aero Jump)")
                            Spacer()
                            Text("\(result.aerodynamicJumpCM, format: .number.precision(.fractionLength(1))) cm (\(result.aerodynamicJumpMOA, format: .number.precision(.fractionLength(2))) MOA)")
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                        }
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
            syncManualWind()
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
        .onChange(of: manualWindSpeed) { _, _ in
            triggerCalculation()
        }
        .onChange(of: windDirectionDegrees) { _, _ in
            triggerCalculation()
        }
        .onChange(of: enableELR) { _, _ in
            triggerCalculation()
        }
        .onChange(of: inclineAngleDegrees) { _, _ in
            triggerCalculation()
        }
        .onChange(of: shootingAzimuthDegrees) { _, _ in
            triggerCalculation()
        }
        .onChange(of: locationManager?.headingDegrees) { _, newHeading in
            if liveCompassActive, let newHeading {
                shootingAzimuthDegrees = newHeading
                triggerCalculation()
            }
        }
        .onChange(of: sensorManager?.currentInclineDegrees) { _, newIncline in
            if liveInclinometerActive, let newIncline {
                inclineAngleDegrees = newIncline
                triggerCalculation()
            }
        }
        .onChange(of: sensorManager?.currentPressureHPa) { _, _ in
            if useOfflineSensors {
                triggerCalculation()
            }
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
            syncManualWind()
            await calculateTrajectory()
        }
    }

    private func syncManualWind() {
        if let weather = weatherManager?.currentWeather {
            manualWindSpeed = weather.wind.speed.converted(to: .kilometersPerHour).value
            windDirectionDegrees = weather.wind.direction.value
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
            .environment(\.sensorService, SensorManager())
    }
    .modelContainer(for: Weapon.self, inMemory: true)
}

