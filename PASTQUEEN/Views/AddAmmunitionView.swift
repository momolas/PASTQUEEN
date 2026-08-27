//
//  AddAmmunitionView.swift
//  PASTQUEEN
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
            if !filteredPresets.isEmpty {
                Section(header: Text("Popular Market Loads")) {
                    Picker("Pre-populate from preset", selection: $selectedPreset) {
                        Text("Custom / Manual").tag(nil as MarketAmmunition?)
                        ForEach(filteredPresets) { preset in
                            Text("\(preset.manufacturer) \(preset.name)").tag(preset as MarketAmmunition?)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
            }

            Section(.ammunitionDetails) {
                TextField(String(localized: .ammunitionName), text: $name)
                TextField(String(localized: .manufacturer), text: $projectileManufacturer)
                TextField(String(localized: .projectileWeightGrains), value: $projectileWeightGrains, format: .number)
            }

            Section(.ballisticData) {
                TextField(String(localized: .ballisticCoefficient), value: $ballisticCoefficient, format: .number)
                TextField(String(localized: .muzzleVelocity), value: $muzzleVelocityMPS, format: .number)
                TextField(String(localized: .muzzleEnergy), value: $muzzleEnergy, format: .number)
                Picker(String(localized: .dragFunction), selection: $dragFunction) {
                    ForEach(AmmunitionData.dragFunctions) { function in
                        Text(function.name).tag(function.id)
                    }
                }
            }

            Section(header: Text("Sensibilité thermique de la poudre (dv/dT)")) {
                HStack {
                    Text("Variation V0 par °C")
                    Spacer()
                    TextField("dv/dT", value: $powderSensitivityMPSPerC, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("m/s / °C")
                        .foregroundStyle(.secondary)
                }
                Text("Ajuste automatiquement la vitesse initiale en fonction de la température ambiante du pas de tir (0 = désactivé).")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button(.save) {
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
                    do {
                        try modelContext.save()
                    } catch {
                        print("Failed to save context after inserting ammunition: \(error)")
                    }
                    dismiss()
                }
                .disabled(!isFormValid)
            }
        }

        .onChange(of: selectedPreset) { _, newPreset in
            if let preset = newPreset {
                name = preset.name
                projectileManufacturer = preset.manufacturer
                projectileWeightGrains = preset.projectileWeightGrains
                ballisticCoefficient = preset.ballisticCoefficient
                dragFunction = preset.dragFunction
                muzzleVelocityMPS = preset.muzzleVelocityMPS
                muzzleEnergy = preset.muzzleEnergyJoules
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(String(localized: .addAmmunition))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    let sampleWeapon = Weapon(name: "Preview Rifle", calibre: ".308", sightHeightCM: 4.5, zeroRangeMeters: 100.0)
    AddAmmunitionView(weapon: sampleWeapon)
        .modelContainer(for: Weapon.self, inMemory: true)
}
