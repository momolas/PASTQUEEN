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

    @State private var showingEditWeapon = false
    @State private var showingEditAmmunition = false

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
            
            Section(header: HStack {
                Text(.weaponCalibration)
                Spacer()
                Button("Modifier la carabine", systemImage: "pencil") {
                    showingEditWeapon = true
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            }) {
                LabeledContent(String(localized: .rifleModel), value: weapon.name)
                LabeledContent(String(localized: .caliber), value: weapon.calibre)
                LabeledContent(String(localized: .sightHeight), value: "\(weapon.sightHeightCM.formatted()) cm")
                LabeledContent(String(localized: .zeroRangeLabel), value: "\(weapon.zeroRangeMeters.formatted()) m")
                LabeledContent("Pas de rayure", value: "1:\(weapon.twistRateInches.formatted()) pouces (\(weapon.twistDirection.rawValue))")
                LabeledContent(String(localized: .scopeClickUnit), value: weapon.scopeClickUnit.rawValue)
            }

            Section(header: HStack {
                Text(.ammunitionDetails)
                Spacer()
                Button("Modifier le chargement", systemImage: "pencil") {
                    showingEditAmmunition = true
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            }) {
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
                
                NavigationLink(value: TruingConfig(weapon: weapon, ammunition: ammunition)) {
                    Label("Étalonner la trajectoire (Truing)", systemImage: "gauge.with.dots.needle.bottom.50percent")
                        .bold()
                        .foregroundStyle(.indigo)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                NavigationLink(value: PBRConfig(weapon: weapon, ammunition: ammunition)) {
                    Label("Tir Tendu & Zone Vitale (DRO / PBR)", systemImage: "scope")
                        .bold()
                        .foregroundStyle(.teal)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle(String(localized: .details))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditWeapon) {
            NavigationStack {
                EditWeaponView(weapon: weapon)
            }
        }
        .sheet(isPresented: $showingEditAmmunition) {
            NavigationStack {
                EditAmmunitionView(ammunition: ammunition)
            }
        }
        .navigationDestination(for: Weapon.self) { weapon in
            CalculatorView(weapon: weapon)
        }
        .navigationDestination(for: RangeCardConfig.self) { config in
            RangeCardView(weapon: config.weapon, ammunition: config.ammunition)
        }
        .navigationDestination(for: TruingConfig.self) { config in
            TruingView(weapon: config.weapon, ammunition: config.ammunition)
        }
        .navigationDestination(for: PBRConfig.self) { config in
            Form {
                PBRView(weapon: config.weapon, ammunition: config.ammunition)
            }
            .navigationTitle("Tir Tendu (PBR)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PBRConfig: Hashable {
    let weapon: Weapon
    let ammunition: Ammunition
    
    static func == (lhs: PBRConfig, rhs: PBRConfig) -> Bool {
        lhs.weapon.id == rhs.weapon.id && lhs.ammunition.id == rhs.ammunition.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(weapon.id)
        hasher.combine(ammunition.id)
    }
}

struct TruingConfig: Hashable {
    let weapon: Weapon
    let ammunition: Ammunition
    
    static func == (lhs: TruingConfig, rhs: TruingConfig) -> Bool {
        lhs.weapon.id == rhs.weapon.id && lhs.ammunition.id == rhs.ammunition.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(weapon.id)
        hasher.combine(ammunition.id)
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
