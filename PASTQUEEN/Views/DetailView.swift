//
//  DetailView.swift
//  PASTQUEEN
//
//  Created by Mo on 27/08/2026.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    let weapon: Weapon
    let ammunition: Ammunition

    @State private var showingEditWeapon = false
    @State private var showingEditAmmunition = false

    var body: some View {
        List {
            // Hero Header
            Section {
                VStack(spacing: 6) {
                    Image(systemName: "scope")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue)
                        .padding(.top, 8)

                    Text(ammunition.name)
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text("\(weapon.name) • \(weapon.calibre)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 6)
                .listRowBackground(Color.clear)
            }

            // Quick Actions Links
            Section {
                NavigationLink(value: RangeCardConfig(weapon: weapon, ammunition: ammunition)) {
                    Label("Table de Tir (DOPE)", systemImage: "tablecells")
                        .font(.headline)
                        .foregroundStyle(.blue)
                }

                NavigationLink(value: TruingConfig(weapon: weapon, ammunition: ammunition)) {
                    Label("Étalonnage Terrain (Truing)", systemImage: "wand.and.stars")
                        .font(.headline)
                        .foregroundStyle(.purple)
                }

                NavigationLink(value: PBRConfig(weapon: weapon, ammunition: ammunition)) {
                    Label("Tir Tendu & Zone Vitale (DRO)", systemImage: "target")
                        .font(.headline)
                        .foregroundStyle(.green)
                }
            } header: {
                Text("Outils Avancés")
            }

            // Weapon Configuration
            Section {
                LabeledContent("Modèle", value: weapon.name)
                LabeledContent("Calibre", value: weapon.calibre)
                LabeledContent("Hauteur de visée", value: "\(weapon.sightHeightCM.formatted()) cm")
                LabeledContent("Distance de zérotage", value: "\(weapon.zeroRangeMeters.formatted()) m")
                LabeledContent("Pas de rayure", value: "1:\(weapon.twistRateInches.formatted())\" (\(weapon.twistDirection.rawValue))")
                LabeledContent("Unité de tourelle", value: weapon.scopeClickUnit.rawValue)
            } header: {
                HStack {
                    Text("Configuration Carabine")
                    Spacer()
                    Button("Modifier", systemImage: "pencil") {
                        showingEditWeapon = true
                    }
                    .font(.caption)
                    .foregroundStyle(.blue)
                }
            }

            // Ammunition Specs
            Section {
                LabeledContent("Fabricant", value: ammunition.projectileManufacturer)
                LabeledContent("Masse du projectile", value: "\(ammunition.projectileWeightGrains.formatted()) gr")
                LabeledContent("Coefficient Balistique (BC)", value: ammunition.ballisticCoefficient.formatted(.number.precision(.fractionLength(3))))
                LabeledContent("Vitesse initiale (V0)", value: "\(ammunition.muzzleVelocityMPS.formatted(.number.precision(.fractionLength(0)))) m/s")
                LabeledContent("Énergie à la bouche", value: "\(ammunition.muzzleEnergy.formatted(.number.precision(.fractionLength(0)))) J")
                LabeledContent("Sensibilité thermique (dv/dT)", value: "\(ammunition.powderSensitivityMPSPerC.formatted(.number.precision(.fractionLength(2)))) m/s/°C")
            } header: {
                HStack {
                    Text("Données Balistiques Munition")
                    Spacer()
                    Button("Modifier", systemImage: "pencil") {
                        showingEditAmmunition = true
                    }
                    .font(.caption)
                    .foregroundStyle(.blue)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Détails")
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
            PBRView(weapon: config.weapon, ammunition: config.ammunition)
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
