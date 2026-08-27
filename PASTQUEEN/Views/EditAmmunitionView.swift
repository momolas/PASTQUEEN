//
//  EditAmmunitionView.swift
//  PASTQUEEN
//
//  Created by Mo on 27/08/2026.
//

import SwiftUI
import SwiftData

struct EditAmmunitionView: View {
    @Bindable var ammunition: Ammunition
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
                HStack {
                    Label("Nom du chargement", systemImage: "pencil")
                    Spacer()
                    TextField("Nom", text: $name)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Label("Fabricant", systemImage: "building.2")
                    Spacer()
                    TextField("Fabricant", text: $projectileManufacturer)
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
                Button(action: saveChanges) {
                    Text("Enregistrer les modifications")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(!isFormValid)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Modifier la munition")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
        }
        .onAppear {
            name = ammunition.name
            projectileManufacturer = ammunition.projectileManufacturer
            projectileWeightGrains = ammunition.projectileWeightGrains
            ballisticCoefficient = ammunition.ballisticCoefficient
            dragFunction = ammunition.dragFunction
            muzzleVelocityMPS = ammunition.muzzleVelocityMPS
            muzzleEnergy = ammunition.muzzleEnergy
            powderSensitivityMPSPerC = ammunition.powderSensitivityMPSPerC
        }
    }

    private func saveChanges() {
        ammunition.name = name
        ammunition.projectileManufacturer = projectileManufacturer
        ammunition.projectileWeightGrains = projectileWeightGrains
        ammunition.ballisticCoefficient = ballisticCoefficient
        ammunition.dragFunction = dragFunction
        ammunition.muzzleVelocityMPS = muzzleVelocityMPS
        ammunition.muzzleEnergy = muzzleEnergy
        ammunition.powderSensitivityMPSPerC = powderSensitivityMPSPerC
        try? modelContext.save()
        dismiss()
    }
}
