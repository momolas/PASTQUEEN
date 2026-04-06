//
//  DetailView.swift
//  PASTQUEEN
//
//  Created by Mo on 26/10/2022.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    let ballisticSettings: BallisticSettings

    var body: some View {
        VStack(spacing: 20) {
            Text(ballisticSettings.ammunitionName)
                .font(.largeTitle)
                .bold()

            VStack(alignment: .leading, spacing: 10) {
                Text("Caliber: \(ballisticSettings.calibre)")
                Text("BC: \(ballisticSettings.ballisticCoefficient, format: .number.precision(.fractionLength(3)))")
                Text("Muzzle Velocity: \(ballisticSettings.muzzleVelocityMPS, format: .number.precision(.fractionLength(0))) m/s")
                Text("Projectile Weight: \(ballisticSettings.projectileWeightGrains, format: .number.precision(.fractionLength(0))) gr")
                Text("Sight Height: \(ballisticSettings.sightHeightCM, format: .number.precision(.fractionLength(2))) cm")
                Text("Zero Range: \(ballisticSettings.zeroRangeMeters, format: .number.precision(.fractionLength(0))) m")
            }
            .font(.body)

            Spacer()

            NavigationLink(value: ballisticSettings) {
                Text("Calculate Range Card")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 10))
            }
            .padding()
        }
        .padding()
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: BallisticSettings.self) { settings in
            CalculatorView(ballisticSettings: settings)
        }
    }
}

#Preview {
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
        projectileWeightGrains: 168,
        sightHeightCM: 3.81,
        zeroRangeMeters: 100.0
    )
    DetailView(ballisticSettings: sampleBallistics)
        .modelContainer(for: BallisticSettings.self, inMemory: true)
}
