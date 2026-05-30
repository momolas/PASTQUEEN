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
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 60

    var body: some View {
        List {
            Section {
                VStack(alignment: .center) {
                    Image(systemName: "target")
                        .font(.system(size: iconSize))
                        .foregroundStyle(.blue)
                        .padding(.vertical)
                    
                    Text(ballisticSettings.ammunitionName)
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text(ballisticSettings.projectileManufacturer)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            
            Section(header: Text(.ammunitionDetails)) {
                LabeledContent(String(localized: .caliber), value: ballisticSettings.calibre)
                LabeledContent(
                    String(localized: .projectileWeightGrains),
                    value: "\(ballisticSettings.projectileWeightGrains.formatted()) gr"
                )
            }
            
            Section(header: Text(.ballisticData)) {
                LabeledContent(
                    String(localized: .ballisticCoefficient),
                    value: ballisticSettings.ballisticCoefficient.formatted(.number.precision(.fractionLength(3)))
                )
                LabeledContent(
                    String(localized: .muzzleVelocity),
                    value: "\(ballisticSettings.muzzleVelocityMPS.formatted(.number.precision(.fractionLength(0)))) m/s"
                )
                LabeledContent(
                    String(localized: .muzzleEnergy),
                    value: "\(ballisticSettings.muzzleEnergy.formatted(.number.precision(.fractionLength(0)))) J"
                )
            }
            
            Section(header: Text(.rifleSetup)) {
                LabeledContent(
                    String(localized: .sightHeight),
                    value: "\(ballisticSettings.sightHeightCM.formatted(.number.precision(.fractionLength(2)))) cm"
                )
                LabeledContent(
                    String(localized: .zeroRange),
                    value: "\(ballisticSettings.zeroRangeMeters.formatted(.number.precision(.fractionLength(0)))) m"
                )
            }
            
            Section {
                NavigationLink(value: ballisticSettings) {
                    Text(.calculateRangeCard)
                        .bold()
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle(String(localized: .details))
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
