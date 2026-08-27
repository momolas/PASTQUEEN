//
//  DetailView.swift
//  PASTQUEEN
//

import SwiftUI
import SwiftData

struct DetailView: View {
    let weapon: Weapon
    let ammunition: Ammunition
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 60

    var body: some View {
        List {
            Section {
                VStack(alignment: .center) {
                    Image(systemName: "target")
                        .font(.system(size: iconSize))
                        .foregroundStyle(.blue)
                        .padding(.vertical)
                    
                    Text(ammunition.name)
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text(ammunition.projectileManufacturer)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            
            Section(header: Text(.weaponCalibration)) {
                LabeledContent(String(localized: .rifleModel), value: weapon.name)
                LabeledContent(String(localized: .caliber), value: weapon.calibre)
                LabeledContent(String(localized: .sightHeight), value: "\(weapon.sightHeightCM.formatted()) cm")
                LabeledContent(String(localized: .zeroRangeLabel), value: "\(weapon.zeroRangeMeters.formatted()) m")
                LabeledContent("Pas de rayure", value: "1:\(weapon.twistRateInches.formatted()) pouces (\(weapon.twistDirection.rawValue))")
                LabeledContent(String(localized: .scopeClickUnit), value: weapon.scopeClickUnit.rawValue)
            }

            
            Section(header: Text(.ammunitionDetails)) {
                LabeledContent(
                    String(localized: .projectileWeightGrains),
                    value: "\(ammunition.projectileWeightGrains.formatted()) gr"
                )
            }
            
            Section(header: Text(.ballisticData)) {
                LabeledContent(
                    String(localized: .ballisticCoefficient),
                    value: ammunition.ballisticCoefficient.formatted(.number.precision(.fractionLength(3)))
                )
                LabeledContent(
                    String(localized: .muzzleVelocity),
                    value: "\(ammunition.muzzleVelocityMPS.formatted(.number.precision(.fractionLength(0)))) m/s"
                )
                LabeledContent(
                    String(localized: .muzzleEnergy),
                    value: "\(ammunition.muzzleEnergy.formatted(.number.precision(.fractionLength(0)))) J"
                )
            }
            
            Section {
                NavigationLink(value: RangeCardConfig(weapon: weapon, ammunition: ammunition)) {
                    Text(.calculateRangeCard)
                        .bold()
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle(String(localized: .details))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Weapon.self) { weapon in
            CalculatorView(weapon: weapon)
        }
        .navigationDestination(for: RangeCardConfig.self) { config in
            RangeCardView(weapon: config.weapon, ammunition: config.ammunition)
        }
    }
}

struct RangeCardConfig: Hashable {
    let weapon: Weapon
    let ammunition: Ammunition
    
    static func == (lhs: RangeCardConfig, rhs: RangeCardConfig) -> Bool {
        lhs.weapon.id == rhs.weapon.id && lhs.ammunition.id == rhs.ammunition.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(weapon.id)
        hasher.combine(ammunition.id)
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
    DetailView(weapon: sampleWeapon, ammunition: sampleAmmo)
        .modelContainer(for: Weapon.self, inMemory: true)
}
