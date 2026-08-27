//
//  QuickHUDView.swift
//  PASTQUEEN
//
//  Created by Mo on 27/08/2026.
//

import SwiftUI
import SwiftData
import Ballistics

enum QuickHUDRoute: Hashable {
    case calculator
    case rangeCard
}


struct QuickHUDView: View {
    @Bindable var weapon: Weapon


    @Environment(\.locationService) private var locationManager
    @Environment(\.weatherService) private var weatherManager
    @Environment(\.sensorService) private var sensorManager

    @State private var selectedAmmunition: Ammunition?
    @State private var distance: Double = 100.0
    @State private var manualWindSpeed: Double = 10.0
    @State private var windDirectionDegrees: Double = 90.0

    // ELR & Angles
    @State private var enableELR = false
    @State private var inclineAngleDegrees: Double = 0.0
    @State private var shootingAzimuthDegrees: Double = 0.0
    @State private var liveCompassActive = false
    @State private var liveInclinometerActive = false

    // Moving Target
    @State private var enableMovingTarget = false
    @State private var targetSpeedKMH: Double = 15.0
    @State private var targetDirectionRight = true

    // Navigation & Sheets
    @State private var showingProfiles = false
    @State private var showingWindPicker = false
    @State private var trajectoryResult: TrajectoryResult = .empty

    private var currentAmmo: Ammunition? {
        selectedAmmunition ?? weapon.ammunitions?.sorted(by: { $0.date > $1.date }).first
    }

    private func getCalculator() -> BallisticCalculator {
        let localPressure = (sensorManager?.currentPressureHPa != nil)
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

        let ammo = currentAmmo
        let settings = BallisticSettings(
            ammunitionName: ammo?.name ?? "Default",
            ballisticCoefficient: ammo?.ballisticCoefficient ?? 0.45,
            calibre: weapon.calibre,
            date: ammo?.date ?? Date().timeIntervalSince1970,
            distanceMeters: distance,
            dragFunction: ammo?.dragFunction ?? 1,
            id: ammo?.id ?? UUID(),
            muzzleEnergy: ammo?.muzzleEnergy ?? 3500.0,
            muzzleVelocityMPS: ammo?.muzzleVelocityMPS ?? 800.0,
            projectileManufacturer: ammo?.projectileManufacturer ?? "Default",
            projectileWeightGrains: ammo?.projectileWeightGrains ?? 168.0,
            sightHeightCM: weapon.sightHeightCM,
            zeroRangeMeters: weapon.zeroRangeMeters,
            powderSensitivityMPSPerC: ammo?.powderSensitivityMPSPerC ?? 0.0,
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
        ScrollView {
            VStack(spacing: 12) {
                // 1. Floating Weapon & Ammo Selector Pill
                QuickWeaponHeaderCard(
                    weapon: weapon,
                    currentAmmo: currentAmmo,
                    onSelectAmmo: { ammo in
                        selectedAmmunition = ammo
                        recalculate()
                    }
                )

                // 2. Minimalist Distance Hero Card
                QuickDistanceCard(
                    distance: $distance,
                    onDistanceChange: recalculate
                )

                // 3. Environmental Translucent Chips
                EnvironmentalStatusPills(
                    manualWindSpeed: manualWindSpeed,
                    windDirectionDegrees: windDirectionDegrees,
                    inclineAngleDegrees: inclineAngleDegrees,
                    shootingAzimuthDegrees: shootingAzimuthDegrees,
                    liveInclinometerActive: $liveInclinometerActive,
                    liveCompassActive: $liveCompassActive,
                    enableMovingTarget: $enableMovingTarget,
                    targetSpeedKMH: targetSpeedKMH,
                    targetDirectionRight: targetDirectionRight,
                    onTapWind: { showingWindPicker = true },
                    onToggleIncline: {
                        if liveInclinometerActive {
                            sensorManager?.startInclineMonitoring()
                        } else {
                            sensorManager?.stopInclineMonitoring()
                        }
                    },
                    onToggleCompass: {
                        if liveCompassActive {
                            locationManager?.startUpdatingHeading()
                        } else {
                            locationManager?.stopUpdatingHeading()
                        }
                    },
                    onToggleMovingTarget: recalculate
                )

                // 4. Ultra-Clean Correction Badges
                QuickHUDBadges(
                    result: trajectoryResult,
                    scopeUnit: weapon.scopeClickUnit
                )

                // 5. Tactical Optical Scope
                ReticleView(
                    result: trajectoryResult,
                    scopeUnit: weapon.scopeClickUnit,
                    distanceMeters: distance,
                    showHUD: false
                )

                // 6. Minimalist Bottom Action Links
                QuickHUDNavButtons(weapon: weapon, currentAmmo: currentAmmo)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
            }
            .padding(.top, 4)
        }
        .navigationTitle("HUD de Tir")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Armes", systemImage: "list.bullet") {
                    showingProfiles = true
                }
                .labelStyle(.iconOnly)
            }

            ToolbarItem(placement: .primaryAction) {
                NavigationLink(value: QuickHUDRoute.calculator) {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
        .navigationDestination(for: QuickHUDRoute.self) { route in
            switch route {
            case .calculator:
                CalculatorView(weapon: weapon)
            case .rangeCard:
                if let ammo = currentAmmo {
                    RangeCardView(weapon: weapon, ammunition: ammo)
                }
            }
        }
        .sheet(isPresented: $showingProfiles) {
            NavigationStack {
                WeaponListView(selectedWeapon: .constant(weapon))
            }
        }
        .sheet(isPresented: $showingWindPicker) {
            WindPickerSheet(
                windDirectionDegrees: $windDirectionDegrees,
                manualWindSpeed: $manualWindSpeed
            ) {
                showingWindPicker = false
                recalculate()
            }
            .presentationDetents([.medium])
        }
        .task {
            recalculate()
        }
        .onChange(of: sensorManager?.currentInclineDegrees) { _, newIncline in
            if liveInclinometerActive, let newIncline {
                inclineAngleDegrees = newIncline
                recalculate()
            }
        }
        .onChange(of: locationManager?.headingDegrees) { _, newHeading in
            if liveCompassActive, let newHeading {
                shootingAzimuthDegrees = newHeading
                recalculate()
            }
        }
    }

    private func recalculate() {
        let calc = getCalculator()
        self.trajectoryResult = calc.solveTrajectory(for: distance)
    }
}

// MARK: - Subviews

struct QuickWeaponHeaderCard: View {
    let weapon: Weapon
    let currentAmmo: Ammunition?
    let onSelectAmmo: (Ammunition) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "scope")
                .font(.caption)
                .foregroundStyle(.blue)

            Text(weapon.name)
                .font(.subheadline)
                .bold()

            if let ammo = currentAmmo {
                Text("•")
                    .foregroundStyle(.tertiary)
                Text(ammo.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            let ammoList = weapon.ammunitions?.sorted(by: { $0.date > $1.date }) ?? []
            if ammoList.count > 1 {
                Menu {
                    ForEach(ammoList) { ammo in
                        Button(ammo.name) {
                            onSelectAmmo(ammo)
                        }
                    }
                } label: {
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.horizontal)
    }
}

struct QuickDistanceCard: View {
    @Binding var distance: Double
    let onDistanceChange: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(Int(distance))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("m")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 14) {
                Button {
                    if distance > 25 {
                        distance = max(distance - 25, 25)
                        onDistanceChange()
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Slider(value: $distance, in: 25...1000, step: 25)
                    .tint(.blue)
                    .sensoryFeedback(.selection, trigger: distance)
                    .onChange(of: distance) { _, _ in
                        onDistanceChange()
                    }

                Button {
                    if distance < 1000 {
                        distance = min(distance + 25, 1000)
                        onDistanceChange()
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .padding(.horizontal)
    }
}

struct EnvironmentalStatusPills: View {
    let manualWindSpeed: Double
    let windDirectionDegrees: Double
    let inclineAngleDegrees: Double
    let shootingAzimuthDegrees: Double
    @Binding var liveInclinometerActive: Bool
    @Binding var liveCompassActive: Bool
    @Binding var enableMovingTarget: Bool
    let targetSpeedKMH: Double
    let targetDirectionRight: Bool
    let onTapWind: () -> Void
    let onToggleIncline: () -> Void
    let onToggleCompass: () -> Void
    let onToggleMovingTarget: () -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                Button(action: onTapWind) {
                    HStack(spacing: 4) {
                        Image(systemName: "wind")
                        Text("\(manualWindSpeed, format: .number.precision(.fractionLength(0))) km/h à \(Int(windDirectionDegrees))°")
                    }
                    .font(.caption2)
                    .bold()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    liveInclinometerActive.toggle()
                    onToggleIncline()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: liveInclinometerActive ? "level.fill" : "level")
                        Text("\(inclineAngleDegrees, format: .number.precision(.fractionLength(0)))°")
                    }
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(liveInclinometerActive ? .green : .primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    liveCompassActive.toggle()
                    onToggleCompass()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: liveCompassActive ? "location.north.line.fill" : "safari")
                        Text("\(Int(shootingAzimuthDegrees))°")
                    }
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(liveCompassActive ? .green : .primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    enableMovingTarget.toggle()
                    onToggleMovingTarget()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "figure.run")
                        Text(enableMovingTarget ? "\(targetSpeedKMH, format: .number.precision(.fractionLength(0))) km/h \(targetDirectionRight ? "➔" : "⬅")" : "Fixe")
                    }
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(enableMovingTarget ? .cyan : .secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
}

struct QuickHUDBadges: View {
    let result: TrajectoryResult
    let scopeUnit: ScopeClickUnit

    private var dropClicks: Int {
        scopeUnit.clicks(forMOACorrection: result.totalDropCorrectionMOA)
    }

    private var windageClicks: Int {
        scopeUnit.clicks(forMOACorrection: result.totalWindageCorrectionMOA)
    }

    private var windageDirection: String {
        result.totalWindageCorrectionMOA >= 0 ? "D" : "G"
    }

    private var elevationHoldoverUnits: Double {
        switch scopeUnit {
        case .mrad10:
            return result.totalDropCorrectionMOA / 3.43774677
        case .moa14, .moa18:
            return result.totalDropCorrectionMOA
        }
    }

    private var windageHoldoverUnits: Double {
        switch scopeUnit {
        case .mrad10:
            return result.totalWindageCorrectionMOA / 3.43774677
        case .moa14, .moa18:
            return result.totalWindageCorrectionMOA
        }
    }

    private var unitLabel: String {
        switch scopeUnit {
        case .mrad10: return "MIL"
        case .moa14, .moa18: return "MOA"
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            VStack(spacing: 2) {
                Text("ÉLÉVATION")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.blue)

                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundStyle(.blue)
                    Text("\(dropClicks) clics")
                        .font(.title3)
                        .bold()
                        .fontDesign(.rounded)
                }

                Text("\(elevationHoldoverUnits, format: .number.precision(.fractionLength(1))) \(unitLabel)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 14))

            VStack(spacing: 2) {
                Text("DÉRIVE / AVANCE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.orange)

                HStack(spacing: 4) {
                    Image(systemName: windageDirection == "D" ? "arrow.right.circle.fill" : "arrow.left.circle.fill")
                        .foregroundStyle(.orange)
                    Text("\(windageClicks) clics \(windageDirection)")
                        .font(.title3)
                        .bold()
                        .fontDesign(.rounded)
                }

                Text("\(abs(windageHoldoverUnits), format: .number.precision(.fractionLength(1))) \(unitLabel)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 14))
        }
        .padding(.horizontal)
    }
}

struct QuickHUDNavButtons: View {
    let weapon: Weapon
    let currentAmmo: Ammunition?

    var body: some View {
        HStack(spacing: 10) {
            NavigationLink(value: QuickHUDRoute.calculator) {
                Label("Calculateur", systemImage: "slider.horizontal.3")
                    .font(.footnote)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.15), in: .rect(cornerRadius: 10))
                    .foregroundStyle(.blue)
            }

            NavigationLink(value: QuickHUDRoute.rangeCard) {
                Label("Table DOPE", systemImage: "tablecells")
                    .font(.footnote)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.secondary.opacity(0.12), in: .rect(cornerRadius: 10))
                    .foregroundStyle(.white)
            }
        }
    }
}

struct WindPickerSheet: View {
    @Binding var windDirectionDegrees: Double
    @Binding var manualWindSpeed: Double
    let onValidate: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Direction et Vitesse du Vent")
                    .font(.headline)
                    .padding(.top)

                WindClockPicker(windDirectionDegrees: $windDirectionDegrees)
                    .frame(height: 220)

                HStack {
                    Text("Vitesse :")
                    Spacer()
                    TextField("Vent", value: $manualWindSpeed, format: .number.precision(.fractionLength(0)))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 70)
                    Text("km/h")
                }
                .padding(.horizontal)

                Button("Valider", action: onValidate)
                    .buttonStyle(.borderedProminent)
                    .padding()
            }
            .navigationTitle("Vent")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
