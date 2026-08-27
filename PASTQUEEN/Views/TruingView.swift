//
//  TruingView.swift
//  PASTQUEEN
//
//  Created by Mo on 27/08/2026.
//

import SwiftUI
import SwiftData
import Ballistics

enum TruingMode: String, CaseIterable, Identifiable {
    case muzzleVelocity = "Vitesse (V0)"
    case ballisticCoefficient = "Coefficient (BC)"

    var id: String { rawValue }

    var recommendedDistance: Double {
        switch self {
        case .muzzleVelocity: return 300.0
        case .ballisticCoefficient: return 800.0
        }
    }
}

enum TruingInputFormat: String, CaseIterable, Identifiable {
    case clicks = "Clics de tourelle"
    case moa = "MOA"
    case cm = "Écart en cible (cm)"

    var id: String { rawValue }

    var unitSuffix: String {
        switch self {
        case .clicks: return "clics"
        case .moa: return "MOA"
        case .cm: return "cm"
        }
    }
}

struct TruingView: View {
    let weapon: Weapon
    @Bindable var ammunition: Ammunition

    @Environment(\.weatherService) private var weatherManager
    @Environment(\.locationService) private var locationManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var mode: TruingMode = .muzzleVelocity
    @State private var testDistanceMeters: Double = 300.0
    @State private var inputFormat: TruingInputFormat = .clicks
    @State private var observedValue: Double = 0.0

    // Environmental overrides
    @State private var temperatureC: Double = 15.0
    @State private var pressureHPa: Double = 1013.25
    @State private var altitudeMeters: Double = 0.0

    // Results
    @State private var calculatedV0: Double?
    @State private var calculatedBC: Double?
    @State private var errorMessage: String?
    @State private var showAppliedFeedback: Bool = false

    var body: some View {
        Form {
            Section {
                Picker("Objectif", selection: $mode) {
                    ForEach(TruingMode.allCases) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .sensoryFeedback(.selection, trigger: mode)

                Text(mode == .muzzleVelocity
                     ? "Recommandé à 300m-600m. Ajuste la vitesse réelle de votre canon."
                     : "Recommandé à 800m+. Ajuste le coefficient de traînée réel de votre projectile.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Paramètre à étalonner")
            }

            Section {
                HStack {
                    Label("Distance de tir", systemImage: "ruler")
                    Spacer()
                    TextField("Distance", value: $testDistanceMeters, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("m")
                        .foregroundStyle(.secondary)
                }

                Picker("Unité de correction", selection: $inputFormat) {
                    ForEach(TruingInputFormat.allCases) { format in
                        Text(format.rawValue).tag(format)
                    }
                }

                HStack {
                    Label(inputFormat == .clicks ? "Correction réelle" : (inputFormat == .moa ? "Correction MOA" : "Hauteur d'impact"),
                          systemImage: "scope")
                    Spacer()
                    TextField("Valeur", value: $observedValue, format: .number)
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(.trailing)
                    Text(inputFormat.unitSuffix)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Impact mesuré au pas de tir")
            }

            Section {
                HStack {
                    Label("Température", systemImage: "thermometer.medium")
                    Spacer()
                    TextField("Température", value: $temperatureC, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("°C")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("Pression", systemImage: "gauge.with.needle")
                    Spacer()
                    TextField("Pression", value: $pressureHPa, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("hPa")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Conditions météo")
            }

            Section {
                Button("Calculer l'étalonnage", systemImage: "wand.and.stars") {
                    performTruing()
                }
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
            }

            if let error = errorMessage {
                Section {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }

            if let newV0 = calculatedV0 {
                Section {
                    TruingV0ResultContent(
                        currentV0: ammunition.muzzleVelocityMPS,
                        calibratedV0: newV0,
                        onApply: {
                            ammunition.muzzleVelocityMPS = newV0
                            let massKg = (ammunition.projectileWeightGrains * 0.06479891) / 1000.0
                            ammunition.muzzleEnergy = 0.5 * massKg * newV0 * newV0
                            try? modelContext.save()
                            showAppliedFeedback.toggle()
                        }
                    )
                } header: {
                    Text("Résultat V0 calibrée")
                }
            } else if let newBC = calculatedBC {
                Section {
                    TruingBCResultContent(
                        currentBC: ammunition.ballisticCoefficient,
                        calibratedBC: newBC,
                        onApply: {
                            ammunition.ballisticCoefficient = newBC
                            try? modelContext.save()
                            showAppliedFeedback.toggle()
                        }
                    )
                } header: {
                    Text("Résultat BC calibré")
                }
            }
        }
        .navigationTitle("Étalonnage (Truing)")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: showAppliedFeedback)
        .onAppear {
            initWeatherDefaults()
            testDistanceMeters = mode.recommendedDistance
            initDefaultObserved()
        }
        .onChange(of: mode) { _, newMode in
            testDistanceMeters = newMode.recommendedDistance
            calculatedV0 = nil
            calculatedBC = nil
            errorMessage = nil
            initDefaultObserved()
        }
    }

    private func initWeatherDefaults() {
        if let weather = weatherManager?.currentWeather {
            temperatureC = weather.temperature.converted(to: .celsius).value
            pressureHPa = weather.pressure.converted(to: .hectopascals).value
        }
        if let loc = locationManager {
            altitudeMeters = loc.altitude ?? 0.0
        }
    }

    private func initDefaultObserved() {
        let calculator = getCalculator()
        let result = calculator.solveTrajectory(for: testDistanceMeters)
        switch inputFormat {
        case .clicks:
            observedValue = Double(weapon.scopeClickUnit.clicks(forMOACorrection: result.dropCorrectionMOA))
        case .moa:
            observedValue = result.dropCorrectionMOA
        case .cm:
            observedValue = result.dropCM
        }
    }

    private func getCalculator() -> BallisticCalculator {
        let weatherData = BallisticCalculator.WeatherData(
            windSpeed: 0,
            windDirection: 0,
            pressure: pressureHPa,
            temperature: temperatureC,
            humidity: 0.78,
            altitude: altitudeMeters
        )

        let settings = BallisticSettings(
            ammunitionName: ammunition.name,
            ballisticCoefficient: ammunition.ballisticCoefficient,
            calibre: weapon.calibre,
            date: ammunition.date,
            distanceMeters: testDistanceMeters,
            dragFunction: ammunition.dragFunction,
            id: ammunition.id,
            muzzleEnergy: ammunition.muzzleEnergy,
            muzzleVelocityMPS: ammunition.muzzleVelocityMPS,
            projectileManufacturer: ammunition.projectileManufacturer,
            projectileWeightGrains: ammunition.projectileWeightGrains,
            sightHeightCM: weapon.sightHeightCM,
            zeroRangeMeters: weapon.zeroRangeMeters
        )

        return BallisticCalculator(ballistics: settings, weather: weatherData)
    }

    private func computeObservedMOA() -> Double {
        switch inputFormat {
        case .clicks:
            return weapon.scopeClickUnit.moaCorrection(forClicks: Int(observedValue))
        case .moa:
            return observedValue
        case .cm:
            guard testDistanceMeters > 0 else { return 0 }
            let cmPerMOA = 2.908882 * (testDistanceMeters / 100.0)
            return -observedValue / cmPerMOA
        }
    }

    private func performTruing() {
        errorMessage = nil
        calculatedV0 = nil
        calculatedBC = nil

        let observedMOA = computeObservedMOA()
        let atmosphere = Atmosphere(
            altitude: Measurement(value: altitudeMeters, unit: .meters),
            pressure: Measurement(value: pressureHPa, unit: .hectopascals),
            temperature: Measurement(value: temperatureC, unit: .celsius),
            relativeHumidity: 0.78
        )

        let dragFunc: DragFunction
        switch ammunition.dragFunction {
        case 7: dragFunc = .g7
        case 2: dragFunc = .g2
        case 5: dragFunc = .g5
        case 6: dragFunc = .g6
        case 8: dragFunc = .g8
        default: dragFunc = .g1
        }

        switch mode {
        case .muzzleVelocity:
            let result = Truing.calibrateMuzzleVelocity(
                observedDropCorrection: Measurement(value: observedMOA, unit: .minutesOfAngle),
                atDistance: Measurement(value: testDistanceMeters, unit: .meters),
                dragFunction: dragFunc,
                dragCoefficient: ammunition.ballisticCoefficient,
                sightHeight: Measurement(value: weapon.sightHeightCM, unit: .centimeters),
                zeroRange: Measurement(value: weapon.zeroRangeMeters, unit: .meters),
                atmosphere: atmosphere,
                initialVelocityGuess: Measurement(value: ammunition.muzzleVelocityMPS, unit: .metersPerSecond),
                weight: Measurement(value: ammunition.projectileWeightGrains, unit: .grains)
            )

            switch result {
            case .success(let speed):
                calculatedV0 = speed.converted(to: .metersPerSecond).value
            case .failure(let error):
                errorMessage = error.localizedDescription
            }

        case .ballisticCoefficient:
            let result = Truing.calibrateBallisticCoefficient(
                observedDropCorrection: Measurement(value: observedMOA, unit: .minutesOfAngle),
                atDistance: Measurement(value: testDistanceMeters, unit: .meters),
                muzzleVelocity: Measurement(value: ammunition.muzzleVelocityMPS, unit: .metersPerSecond),
                dragFunction: dragFunc,
                sightHeight: Measurement(value: weapon.sightHeightCM, unit: .centimeters),
                zeroRange: Measurement(value: weapon.zeroRangeMeters, unit: .meters),
                atmosphere: atmosphere,
                dragCoefficientGuess: ammunition.ballisticCoefficient,
                weight: Measurement(value: ammunition.projectileWeightGrains, unit: .grains)
            )

            switch result {
            case .success(let bc):
                calculatedBC = bc
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Subview Structs

struct TruingV0ResultContent: View {
    let currentV0: Double
    let calibratedV0: Double
    let onApply: () -> Void

    private var delta: Double {
        calibratedV0 - currentV0
    }

    private var deltaColor: Color {
        if delta == 0 {
            return .secondary
        } else if delta > 0 {
            return .green
        } else {
            return .orange
        }
    }

    var body: some View {
        HStack {
            Text("Vitesse théorique")
            Spacer()
            Text("\(Int(currentV0)) m/s")
                .foregroundStyle(.secondary)
        }

        HStack {
            Text("Vitesse réelle calibrée")
            Spacer()
            Text("\(Int(calibratedV0)) m/s")
                .bold()
                .foregroundStyle(.blue)
        }

        HStack {
            Text("Écart constaté")
            Spacer()
            Text("\(delta >= 0 ? "+" : "")\(Int(delta)) m/s")
                .bold()
                .foregroundStyle(deltaColor)
        }

        Button("Appliquer cette vitesse au rechargement", systemImage: "checkmark.circle.fill", action: onApply)
            .bold()
            .foregroundStyle(.green)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct TruingBCResultContent: View {
    let currentBC: Double
    let calibratedBC: Double
    let onApply: () -> Void

    private var delta: Double {
        calibratedBC - currentBC
    }

    private var percentage: Double {
        guard currentBC > 0 else { return 0 }
        return (delta / currentBC) * 100.0
    }

    private var deltaColor: Color {
        if delta == 0 {
            return .secondary
        } else if delta > 0 {
            return .green
        } else {
            return .orange
        }
    }

    var body: some View {
        HStack {
            Text("BC catalogue")
            Spacer()
            Text(currentBC, format: .number.precision(.fractionLength(3)))
                .foregroundStyle(.secondary)
        }

        HStack {
            Text("BC réel calibré")
            Spacer()
            Text(calibratedBC, format: .number.precision(.fractionLength(3)))
                .bold()
                .foregroundStyle(.blue)
        }

        HStack {
            Text("Écart constaté")
            Spacer()
            Text("\(delta >= 0 ? "+" : "")\(delta.formatted(.number.precision(.fractionLength(3)))) (\(percentage >= 0 ? "+" : "")\(percentage.formatted(.number.precision(.fractionLength(1))))%)")
                .bold()
                .foregroundStyle(deltaColor)
        }

        Button("Appliquer ce BC au rechargement", systemImage: "checkmark.circle.fill", action: onApply)
            .bold()
            .foregroundStyle(.green)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
