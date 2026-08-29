//
//  PASTQUEENApp.swift
//  PASTQUEEN
//
//  Created by Mo on 16/09/2022.
//

import SwiftUI
import SwiftData

@main
struct PASTQUEENApp: App {
    @State private var locationManager = LocationManager()
    @State private var weatherManager = WeatherManager()
    @State private var sensorManager = SensorManager()
    
    private let container: ModelContainer

    init() {
        do {
            let containerInstance = try ModelContainer(for: Weapon.self, Ammunition.self)
            self.container = containerInstance
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            LaunchView()
                .preferredColorScheme(.dark)
                .task {
                    seedInitialDataIfNeeded(context: container.mainContext)
                }
        }
        .environment(\.locationService, locationManager)
        .environment(\.weatherService, weatherManager)
        .environment(\.sensorService, sensorManager)
        .modelContainer(container)
    }

    @MainActor
    private func seedInitialDataIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Weapon>()
        guard let count = try? context.fetchCount(descriptor), count == 0 else { return }

        let savageB22 = Weapon(
            name: "Savage B22",
            calibre: ".22 LR",
            sightHeightCM: 4.0,
            zeroRangeMeters: 50.0,
            scopeClickUnit: .moa18,
            twistRateInches: 16.0,
            twistDirection: .right
        )
        
        let cciSV = Ammunition(
            name: "CCI SV",
            projectileManufacturer: "CCI",
            projectileWeightGrains: 40.0,
            ballisticCoefficient: 0.125,
            dragFunction: 1, // G1
            muzzleVelocityMPS: 326.0,
            muzzleEnergy: 140.0,
            date: Date().timeIntervalSince1970 - 10
        )
        cciSV.weapon = savageB22
        
        let savageAxis = Weapon(
            name: "Savage Axis Varmint",
            calibre: ".308 Win",
            sightHeightCM: 4.5,
            zeroRangeMeters: 100.0,
            scopeClickUnit: .moa18,
            twistRateInches: 10.0,
            twistDirection: .right
        )

        let federalMatch = Ammunition(
            name: "Federal Match 168",
            projectileManufacturer: "Federal",
            projectileWeightGrains: 168.0,
            ballisticCoefficient: 0.462,
            dragFunction: 1, // G1
            muzzleVelocityMPS: 808.0,
            muzzleEnergy: 3525.0,
            date: Date().timeIntervalSince1970
        )
        federalMatch.weapon = savageAxis
        
        context.insert(savageB22)
        context.insert(savageAxis)
        context.insert(cciSV)
        context.insert(federalMatch)
        try? context.save()
    }
}