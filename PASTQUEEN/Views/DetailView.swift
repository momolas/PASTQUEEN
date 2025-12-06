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
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 10) {
                Text("Caliber: \(ballisticSettings.calibre)")
                Text("BC: \(String(format: "%.3f", ballisticSettings.ballisticCoefficient))")
                Text("Muzzle Velocity: \(String(format: "%.0f", ballisticSettings.muzzleVelocityMPS)) m/s")
                Text("Projectile Weight: \(String(format: "%.0f", ballisticSettings.projectileWeightGrains)) gr")
                Text("Sight Height: \(String(format: "%.2f", ballisticSettings.sightHeightCM)) cm")
                Text("Zero Range: \(String(format: "%.0f", ballisticSettings.zeroRangeMeters)) m")
            }
            .font(.body)

            Spacer()

            NavigationLink(destination: CalculatorView(ballisticSettings: ballisticSettings), label: {
                Text("Calculate Range Card")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            })
            .padding()
        }
        .padding()
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let container = try! ModelContainer(for: BallisticSettings.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
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
        return DetailView(ballisticSettings: sampleBallistics)
            .modelContainer(container)
    }
}
