//
//  DetailView.swift
//  PASTQUEEN
//
//  Created by Mo on 26/10/2022.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    let ballisticSettings: Ballistics

    var body: some View {
        VStack(spacing: 20) {
            Text(ballisticSettings.ammunitionName)
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 10) {
                Text("Caliber: \(ballisticSettings.calibre)")
                Text("BC: \(String(format: "%.3f", ballisticSettings.ballisticCoefficient))")
                Text("Muzzle Velocity: \(String(format: "%.0f", ballisticSettings.muzzleVelocity)) ft/s")
                Text("Projectile Weight: \(ballisticSettings.projectileWeight) gr")
                Text("Sight Height: \(String(format: "%.2f", ballisticSettings.sightHeight)) in")
                Text("Zero Range: \(String(format: "%.0f", ballisticSettings.zeroRange)) yds")
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
        let container = try! ModelContainer(for: Ballistics.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let sampleBallistics = Ballistics(
            ammunitionName: "Preview Ammo",
            ballisticCoefficient: 0.45,
            calibre: ".308",
            date: Date().timeIntervalSince1970,
            distanceYards: 100.0,
            dragFunction: 1,
            id: UUID(),
            muzzleEnergy: 2600.0,
            muzzleVelocity: 2800.0,
            projectileManufacturer: "Preview Manufacturer",
            projectileWeight: 168,
            sightHeight: 1.5,
            zeroRange: 100.0
        )
        return DetailView(ballisticSettings: sampleBallistics)
            .modelContainer(container)
    }
}