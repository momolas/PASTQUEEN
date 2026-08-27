//
//  CalculatorView.swift
//  PASTQUEEN
//
//  Created by Mo on 27/08/2026.
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

    // Moving Target State
    @State private var enableMovingTarget = false
    @State private var targetSpeedKMH: Double = 15.0
    @State private var targetDirectionRight = true

    enum CalculatorDisplayMode: String, CaseIterable, Identifiable {
        case hud = "Quick-HUD"
        case turrets = "Tourelles"
        case pbr = "Tir Tendu"

        var id: String { rawValue }
    }

    @State private var displayMode: CalculatorDisplayMode = .hud

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
            altitude: locationManager?.altitude ?? 0.0,
            targetSpeedKMH: enableMovingTarget ? targetSpeedKMH : 0.0,
            targetAngleDegrees: targetDirectionRight ? 90.0 : -90.0
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
            powderSensitivityMPSPerC: selectedAmmunition?.powderSensitivityMPSPerC ?? 0.0,
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
            Section {
                LabeledContent("Modèle", value: weapon.name)
                LabeledContent("Calibre", value: weapon.calibre)
                LabeledContent("Hauteur de visée", value: "\(weapon.sightHeightCM.formatted()) cm")
                LabeledContent("Zéro", value: "\(weapon.zeroRangeMeters.formatted()) m")
                LabeledContent("Pas de rayure", value: "1:\(weapon.twistRateInches.formatted()) (\(weapon.twistDirection.rawValue))")
            } header: {
                Text("Configuration Carabine")
            }

            Section {
                let ammoList = weapon.ammunitions?.sorted(by: { $0.date > $1.date }) ?? []
                if ammoList.isEmpty {
                    NavigationLink(destination: AddAmmunitionView(weapon: weapon)) {
                        Label("Ajouter un chargement", systemImage: "plus.circle")
                            .bold()
                            .foregroundStyle(.blue)
                    }
                } else {
                    Picker(selection: $selectedAmmunition) {
                        ForEach(ammoList) { ammo in
                            Text(ammo.name).tag(ammo as Ammunition?)
                        }
                    } label: {
                        Label("Chargement actif", systemImage: "scope")
                    }

                    NavigationLink(destination: AddAmmunitionView(weapon: weapon)) {
                        Label("Nouveau chargement", systemImage: "plus")
                            .font(.footnote)
                            .foregroundStyle(.blue)
                    }
                }
            } header: {
                Text("Munition")
            }

            if let weather = weatherManager?.currentWeather {
                Section {
                    Toggle(isOn: $useOfflineSensors) {
                        Label("Baromètre interne (hors-ligne)", systemImage: "sensor")
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
                        LabeledContent("Pression locale", value: "\(sensorManager?.currentPressureHPa?.formatted(.number.precision(.fractionLength(1))) ?? "Lecture...") hPa")
                    }

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Température")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("\(weather.temperature.converted(to: .celsius).value, format: .number.precision(.fractionLength(0)))°C")
                                .font(.headline)
                                .fontDesign(.rounded)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Vent")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("\(weather.wind.speed.converted(to: .kilometersPerHour).value, format: .number.precision(.fractionLength(0))) km/h")
                                .font(.headline)
                                .fontDesign(.rounded)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Pression")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("\(weather.pressure.converted(to: .hectopascals).value, format: .number.precision(.fractionLength(0))) hPa")
                                .font(.headline)
                                .fontDesign(.rounded)
                        }
                    }
                } header: {
                    HStack {
                        Text("Conditions Météo")
                        Spacer()
                        Button("Actualiser", systemImage: "arrow.clockwise", action: refreshWeather)
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }

            Section {
                HStack {
                    Label("Distance de la cible", systemImage: "ruler")
                    Spacer()
                    TextField("Distance", value: $distance, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("m")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Distance")
            }

            Section {
                HStack {
                    Label("Vitesse du vent", systemImage: "wind")
                    Spacer()
                    TextField("Vitesse", value: $manualWindSpeed, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 70)
                    Text("km/h")
                        .foregroundStyle(.secondary)
                }

                WindClockPicker(windDirectionDegrees: $windDirectionDegrees)
            } header: {
                Text("Vent")
            }

            // Advanced ELR Module Section
            Section {
                Toggle(isOn: $enableELR) {
                    Text("Activer corrections ELR")
                        .bold()
                }

                if enableELR {
                    // Incline Angle
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Label("Angle de site (Pente)", systemImage: "level")
                            Spacer()
                            TextField("Angle", value: $inclineAngleDegrees, format: .number.precision(.fractionLength(1)))
                                .keyboardType(.numbersAndPunctuation)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 70)
                            Text("°")
                                .foregroundStyle(.secondary)
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
                                liveInclinometerActive ? "Inclinomètre Actif" : "Mesurer l'angle (Capteur)",
                                systemImage: liveInclinometerActive ? "level.fill" : "level"
                            )
                            .font(.caption)
                            .foregroundStyle(liveInclinometerActive ? .green : .blue)
                        }
                    }

                    // Azimuth
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Label("Azimut de tir (Cap)", systemImage: "safari")
                            Spacer()
                            TextField("Azimut", value: $shootingAzimuthDegrees, format: .number.precision(.fractionLength(0)))
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 70)
                            Text("°")
                                .foregroundStyle(.secondary)
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
                                liveCompassActive ? "Boussole Active" : "Capturer le cap (Boussole)",
                                systemImage: liveCompassActive ? "location.north.line.fill" : "safari"
                            )
                            .font(.caption)
                            .foregroundStyle(liveCompassActive ? .green : .blue)
                        }
                    }

                    if let lat = locationManager?.latitude {
                        LabeledContent("Latitude", value: "\(lat.formatted(.number.precision(.fractionLength(2))))°")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Label("Très Longue Distance (ELR)", systemImage: "globe.europe.africa.fill")
            }

            Section {
                Toggle(isOn: $enableMovingTarget) {
                    Label("Activer correction cible mobile", systemImage: "figure.run")
                }

                if enableMovingTarget {
                    HStack {
                        Text("Vitesse de déplacement")
                        Spacer()
                        TextField("Vitesse", value: $targetSpeedKMH, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("km/h")
                            .foregroundStyle(.secondary)
                    }

                    Picker("Direction", selection: $targetDirectionRight) {
                        Text("Gauche ➔ Droite (90°)").tag(true)
                        Text("Droite ➔ Gauche (-90°)").tag(false)
                    }
                }
            } header: {
                Text("Cible Mobile (Moving Target)")
            }

            Section {
                Button(action: triggerCalculation) {
                    Text("Calculer la trajectoire")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            Section {
                Picker("Mode d'affichage", selection: $displayMode) {
                    ForEach(CalculatorDisplayMode.allCases) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
            }

            if displayMode == .hud {
                if let result = trajectoryResult {
                    Section {
                        ReticleView(
                            result: result,
                            scopeUnit: weapon.scopeClickUnit,
                            distanceMeters: distance,
                            showHUD: true
                        )
                    }
                }
            } else if displayMode == .turrets {
                if let result = trajectoryResult {
                    Section {
                        HStack {
                            Text("Chute en cible")
                            Spacer()
                            Text("\(result.totalDropCM, format: .number.precision(.fractionLength(1))) cm")
                                .fontDesign(.rounded)
                        }
                        HStack {
                            Text("Correction en MOA")
                            Spacer()
                            Text("\(result.totalDropCorrectionMOA, format: .number.precision(.fractionLength(2))) MOA")
                                .fontDesign(.rounded)
                        }

                        let dropClicks = weapon.scopeClickUnit.clicks(forMOACorrection: result.totalDropCorrectionMOA)
                        let dropDirectionKey: LocalizedStringResource = result.totalDropCorrectionMOA >= 0 ? .up : .down
                        HStack {
                            Text("Tourelle Élévation")
                            Spacer()
                            Text("\(dropClicks) clics (\(Text(dropDirectionKey).bold().foregroundStyle(.blue)))")
                                .bold()
                        }
                        .fontDesign(.rounded)

                        HStack {
                            Text("Dérive vent")
                            Spacer()
                            Text("\(result.totalWindageCM, format: .number.precision(.fractionLength(1))) cm")
                                .fontDesign(.rounded)
                        }
                        HStack {
                            Text("Correction Dérive")
                            Spacer()
                            Text("\(result.totalWindageCorrectionMOA, format: .number.precision(.fractionLength(2))) MOA")
                                .fontDesign(.rounded)
                        }

                        let windageClicks = weapon.scopeClickUnit.clicks(forMOACorrection: result.totalWindageCorrectionMOA)
                        let windageDirectionKey: LocalizedStringResource = result.totalWindageCorrectionMOA >= 0 ? .right : .left
                        HStack {
                            Text("Tourelle Dérive")
                            Spacer()
                            Text("\(windageClicks) clics (\(Text(windageDirectionKey).bold().foregroundStyle(.orange)))")
                                .bold()
                        }
                        .fontDesign(.rounded)

                        HStack {
                            Text("Vitesse résiduelle")
                            Spacer()
                            Text("\(result.velocityMPS, format: .number.precision(.fractionLength(0))) m/s")
                                .fontDesign(.rounded)
                        }
                        HStack {
                            Text("Énergie résiduelle")
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
                    } header: {
                        Text("Résultats à \(Int(distance)) mètres")
                    }

                    if enableELR || enableMovingTarget {
                        Section {
                            if enableELR {
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

                            if enableMovingTarget && abs(result.movingTargetLeadCM) > 0.01 {
                                HStack {
                                    Text("Avance Cible Mobile (Lead)")
                                    Spacer()
                                    Text("\(result.movingTargetLeadCM, format: .number.precision(.fractionLength(1))) cm (\(result.movingTargetLeadMOA, format: .number.precision(.fractionLength(2))) MOA)")
                                        .bold()
                                        .foregroundStyle(.cyan)
                                }
                            }
                        } header: {
                            Text("Décomposition des Corrections")
                        }
                    }
                }

                if !trajectoryData.isEmpty {
                    Section {
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
                    } header: {
                        Text("Trajectoire (Courbe de Flèche)")
                    }
                }
            } else if displayMode == .pbr {
                if let ammo = selectedAmmunition {
                    Section {
                        PBRView(weapon: weapon, ammunition: ammo)
                    }
                }
            }
        }
        .navigationTitle("Calculateur")
        .navigationBarTitleDisplayMode(.inline)
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
        .onChange(of: enableMovingTarget) { _, _ in
            triggerCalculation()
        }
        .onChange(of: targetSpeedKMH) { _, _ in
            triggerCalculation()
        }
        .onChange(of: targetDirectionRight) { _, _ in
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
