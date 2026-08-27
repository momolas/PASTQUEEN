//
//  RangeCardView.swift
//  PASTQUEEN
//

import SwiftUI
import SwiftData

struct RangeCardRow: Identifiable {
    let id = UUID()
    let distance: Int
    let dropCM: Double
    let dropMOA: Double
    let dropClicks: Int
    let windageCM: Double
    let windageMOA: Double
    let windageClicks: Int
    let velocity: Double
    let energy: Double
}

struct RangeCardView: View {
    let weapon: Weapon
    let ammunition: Ammunition
    
    @Environment(\.weatherService) private var weatherManager
    @Environment(\.locationService) private var locationManager
    
    @State private var increment = 50
    @State private var maxDistance = 500
    @State private var enableELR = true
    @State private var rows: [RangeCardRow] = []
    @State private var isCalculating = false
    
    private let increments = [25, 50, 100]
    private let maxDistances = [300, 500, 800, 1000, 1500]
    
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
            ammunitionName: ammunition.name,
            ballisticCoefficient: ammunition.ballisticCoefficient,
            calibre: weapon.calibre,
            date: ammunition.date,
            distanceMeters: Double(maxDistance),
            dragFunction: ammunition.dragFunction,
            id: ammunition.id,
            muzzleEnergy: ammunition.muzzleEnergy,
            muzzleVelocityMPS: ammunition.muzzleVelocityMPS,
            projectileManufacturer: ammunition.projectileManufacturer,
            projectileWeightGrains: ammunition.projectileWeightGrains,
            sightHeightCM: weapon.sightHeightCM,
            zeroRangeMeters: weapon.zeroRangeMeters,
            powderSensitivityMPSPerC: ammunition.powderSensitivityMPSPerC,
            twistRateInches: weapon.twistRateInches,
            twistDirection: weapon.twistDirection,
            inclineAngleDegrees: 0.0,
            shootingAzimuthDegrees: 0.0,
            latitudeDegrees: locationManager?.latitude ?? 45.0,
            enableELR: enableELR
        )
        
        return BallisticCalculator(ballistics: settings, weather: weatherData)
    }

    
    var body: some View {
        VStack(spacing: 0) {
            // Configuration controls
            Form {
                Section(header: Text("Configuration")) {
                    Picker("Pas (incrément)", selection: $increment) {
                        ForEach(increments, id: \.self) { inc in
                            Text("\(inc) m").tag(inc)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Distance Maximale", selection: $maxDistance) {
                        ForEach(maxDistances, id: \.self) { dist in
                            Text("\(dist) m").tag(dist)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    Toggle("Effets ELR (Spin Drift & Coriolis)", isOn: $enableELR)
                }
            }
            .frame(height: 180)
            
            // Header for table
            HStack {
                Text("Dist (m)")
                    .frame(width: 60, alignment: .leading)
                Spacer()
                Text("Élévation")
                    .frame(width: 100, alignment: .center)
                Spacer()
                Text("Dérive")
                    .frame(width: 100, alignment: .center)
                Spacer()
                Text("Vitesse")
                    .frame(width: 60, alignment: .trailing)
            }
            .font(.caption)
            .bold()
            .foregroundStyle(.secondary)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            
            if isCalculating {
                Spacer()
                ProgressView("Calcul de la table...")
                    .fontDesign(.rounded)
                Spacer()
            } else {
                List(rows) { row in
                    HStack {
                        // Distance column
                        Text("\(row.distance) m")
                            .font(.headline)
                            .fontDesign(.rounded)
                            .frame(width: 60, alignment: .leading)
                        
                        Spacer()
                        
                        // Elevation correction column
                        VStack(alignment: .center, spacing: 2) {
                            Text("\(row.dropClicks) clics")
                                .bold()
                                .foregroundStyle(.blue)
                            Text("\(row.dropMOA, format: .number.precision(.fractionLength(1))) MOA")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .fontDesign(.rounded)
                        .frame(width: 100, alignment: .center)
                        
                        Spacer()
                        
                        // Windage correction column
                        VStack(alignment: .center, spacing: 2) {
                            Text("\(row.windageClicks) clics")
                                .bold()
                                .foregroundStyle(.orange)
                            Text("\(row.windageMOA, format: .number.precision(.fractionLength(1))) MOA")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .fontDesign(.rounded)
                        .frame(width: 100, alignment: .center)
                        
                        Spacer()
                        
                        // Velocity column
                        Text("\(Int(row.velocity)) m/s")
                            .font(.subheadline)
                            .fontDesign(.rounded)
                            .frame(width: 60, alignment: .trailing)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Table de Tir")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if let image = renderedCardImage {
                    ShareLink(
                        item: image,
                        preview: SharePreview("\(weapon.name) - \(ammunition.name) - Table de tir", image: image)
                    ) {
                        Label("Exporter la table", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
        .task(id: increment) {
            await calculateCard()
        }
        .task(id: maxDistance) {
            await calculateCard()
        }
        .task(id: enableELR) {
            await calculateCard()
        }
    }
    
    @MainActor
    private var weatherSummaryText: String {
        guard let weather = weatherManager?.currentWeather else { return "" }
        let temp = weather.temperature.converted(to: .celsius).value.formatted(.number.precision(.fractionLength(0)))
        let press = weather.pressure.converted(to: .hectopascals).value.formatted(.number.precision(.fractionLength(0)))
        let wind = weather.wind.speed.converted(to: .kilometersPerHour).value.formatted(.number.precision(.fractionLength(0)))
        return "\(temp)°C • \(press) hPa • Vent \(wind) km/h"
    }

    @MainActor
    private var renderedCardImage: Image? {
        guard !rows.isEmpty else { return nil }
        let card = RangeCardPrintableCard(
            weaponName: weapon.name,
            caliber: weapon.calibre,
            scopeUnit: weapon.scopeClickUnit.rawValue,
            zeroDistance: weapon.zeroRangeMeters,
            ammoName: ammunition.name,
            bulletWeight: ammunition.projectileWeightGrains,
            muzzleVelocity: ammunition.muzzleVelocityMPS,
            weatherSummary: weatherSummaryText,
            rows: rows
        )
        let renderer = ImageRenderer(content: card)
        if let cgImage = renderer.cgImage {
            return Image(decorative: cgImage, scale: 3.0)
        }
        return nil
    }

    private func calculateCard() async {
        isCalculating = true
        let calculator = getCalculator()
        let step = increment
        let maxDist = maxDistance
        let scopeUnit = weapon.scopeClickUnit
        
        let calculated: [RangeCardRow] = await Task.detached {
            var res: [RangeCardRow] = []
            for d in stride(from: step, through: maxDist, by: step) {
                if Task.isCancelled { break }
                let result = calculator.solveTrajectory(for: Double(d))
                let dClicks = scopeUnit.clicks(forMOACorrection: result.totalDropCorrectionMOA)
                let wClicks = scopeUnit.clicks(forMOACorrection: result.totalWindageCorrectionMOA)

                res.append(RangeCardRow(
                    distance: d,
                    dropCM: result.totalDropCM,
                    dropMOA: result.totalDropCorrectionMOA,
                    dropClicks: dClicks,
                    windageCM: result.totalWindageCM,
                    windageMOA: result.totalWindageCorrectionMOA,
                    windageClicks: wClicks,
                    velocity: result.velocityMPS,
                    energy: result.energyJoules
                ))
            }
            return res
        }.value
        
        self.rows = calculated
        self.isCalculating = false
    }
}

#Preview {
    let sampleWeapon = Weapon(name: "Savage Axis Varmint", calibre: ".308 Win", sightHeightCM: 4.5, zeroRangeMeters: 100.0)
    let sampleAmmo = Ammunition(
        name: "Federal Match 168",
        projectileManufacturer: "Federal",
        projectileWeightGrains: 168.0,
        ballisticCoefficient: 0.462,
        dragFunction: 1,
        muzzleVelocityMPS: 808.0,
        muzzleEnergy: 3525.0
    )
    NavigationStack {
        RangeCardView(weapon: sampleWeapon, ammunition: sampleAmmo)
    }
    .modelContainer(for: Weapon.self, inMemory: true)
}
