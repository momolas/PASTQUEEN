//
//  AddAmmunitionView.swift
//  PASTQUEEN
//
//  Created by Mo on 27/08/2026.
//

import SwiftUI
import SwiftData

struct AddAmmunitionView: View {
    let weapon: Weapon
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var projectileManufacturer = ""
    @State private var projectileWeightGrains: Double = 168
    @State private var ballisticCoefficient = 0.462
    @State private var dragFunction: Int32 = 1
    @State private var muzzleVelocityMPS: Double = 800.0
    @State private var muzzleEnergy: Double = 3500.0
    @State private var powderSensitivityMPSPerC: Double = 0.0
    @State private var selectedPreset: MarketAmmunition? = nil
    @State private var isShowingCatalogPicker = false

    private var filteredPresets: [MarketAmmunition] {
        AmmunitionData.commonLoads.filter { preset in
            preset.caliber.localizedStandardContains(weapon.calibre) || weapon.calibre.localizedStandardContains(preset.caliber)
        }
    }

    private var isFormValid: Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        guard !projectileManufacturer.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        guard projectileWeightGrains > 0 else { return false }
        guard ballisticCoefficient > 0 else { return false }
        guard muzzleVelocityMPS > 0 else { return false }
        guard muzzleEnergy > 0 else { return false }
        return true
    }

    var body: some View {
        Form {
            Section {
                Button {
                    isShowingCatalogPicker = true
                } label: {
                    HStack {
                        Label("Parcourir le catalogue d'usine", systemImage: "books.vertical.fill")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if !filteredPresets.isEmpty {
                    Picker(selection: $selectedPreset) {
                        Text("Manuel / Personnalisé").tag(nil as MarketAmmunition?)
                        ForEach(filteredPresets) { preset in
                            Text("\(preset.manufacturer) • \(preset.name)").tag(preset as MarketAmmunition?)
                        }
                    } label: {
                        Label("Sélection rapide", systemImage: "sparkles")
                    }
                }
            } header: {
                Text("Catalogue Constructeurs")
            } footer: {
                Text("Choisissez parmi les munitions manufacturées de référence pour pré-remplir la fiche.")
            }

            Section {
                HStack {
                    Label("Nom du chargement", systemImage: "pencil")
                    Spacer()
                    TextField("Ex: GGG Match 147gr", text: $name)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Label("Fabricant", systemImage: "building.2")
                    Spacer()
                    TextField("Ex: GGG / Federal", text: $projectileManufacturer)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Label("Masse de l'ogive", systemImage: "scalemass")
                    Spacer()
                    TextField("Masse", value: $projectileWeightGrains, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 70)
                    Text("grains")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Désignation du Projectile")
            }

            Section {
                HStack {
                    Label("Coefficient Balistique (BC)", systemImage: "chart.line.uptrend.xyaxis")
                    Spacer()
                    TextField("BC", value: $ballisticCoefficient, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 70)
                }

                Picker(selection: $dragFunction) {
                    ForEach(AmmunitionData.dragFunctions) { function in
                        Text(function.name).tag(function.id)
                    }
                } label: {
                    Label("Modèle de traînée", systemImage: "wind")
                }

                HStack {
                    Label("Vitesse initiale (V0)", systemImage: "speedometer")
                    Spacer()
                    TextField("V0", value: $muzzleVelocityMPS, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 70)
                    Text("m/s")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("Énergie à la bouche (E0)", systemImage: "bolt.fill")
                    Spacer()
                    TextField("E0", value: $muzzleEnergy, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 70)
                    Text("Joules")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Performances Balistiques")
            }

            Section {
                HStack {
                    Label("Sensibilité thermique", systemImage: "thermometer.sun.fill")
                    Spacer()
                    TextField("dv/dT", value: $powderSensitivityMPSPerC, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                    Text("m/s / °C")
                        .foregroundStyle(.secondary)
                }
                Text("Correction automatique de V0 selon la température (0 = désactivé).")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Sensibilité de la Poudre")
            }

            Section {
                Button("Enregistrer la munition", action: saveAmmunition)
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .disabled(!isFormValid)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Nouvelle Munition")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Enregistrer", action: saveAmmunition)
                    .bold()
                    .disabled(!isFormValid)
            }
        }
        .sheet(isPresented: $isShowingCatalogPicker) {
            AmmunitionCatalogPickerSheet(weaponCaliber: weapon.calibre) { ammo in
                applyCatalogAmmunition(ammo)
            }
        }
        .onChange(of: selectedPreset) { _, newPreset in
            if let preset = newPreset {
                applyCatalogAmmunition(preset)
            }
        }
    }

    private func applyCatalogAmmunition(_ ammo: CatalogAmmunition) {
        name = ammo.name
        projectileManufacturer = ammo.manufacturer
        projectileWeightGrains = ammo.projectileWeightGrains
        ballisticCoefficient = ammo.ballisticCoefficient
        dragFunction = ammo.dragFunction
        muzzleVelocityMPS = ammo.muzzleVelocityMPS
        muzzleEnergy = ammo.muzzleEnergyJoules
        powderSensitivityMPSPerC = ammo.powderSensitivityMPSPerC
    }

    private func saveAmmunition() {
        let newAmmunition = Ammunition(
            name: name,
            projectileManufacturer: projectileManufacturer,
            projectileWeightGrains: projectileWeightGrains,
            ballisticCoefficient: ballisticCoefficient,
            dragFunction: dragFunction,
            muzzleVelocityMPS: muzzleVelocityMPS,
            muzzleEnergy: muzzleEnergy,
            powderSensitivityMPSPerC: powderSensitivityMPSPerC,
            date: Date().timeIntervalSince1970
        )
        newAmmunition.weapon = weapon
        modelContext.insert(newAmmunition)
        try? modelContext.save()
        dismiss()
    }
}
