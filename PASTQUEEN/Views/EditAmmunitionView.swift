//
//  EditAmmunitionView.swift
//  PASTQUEEN
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

            Section {
                Button(.save) {
                    ammunition.name = name
                    ammunition.projectileManufacturer = projectileManufacturer
                    ammunition.projectileWeightGrains = projectileWeightGrains
                    ammunition.ballisticCoefficient = ballisticCoefficient
                    ammunition.dragFunction = dragFunction
                    ammunition.muzzleVelocityMPS = muzzleVelocityMPS
                    ammunition.muzzleEnergy = muzzleEnergy
                    
                    do {
                        try modelContext.save()
                    } catch {
                        print("Failed to save modified ammunition: \(error)")
                    }
                    dismiss()
                }
                .disabled(!isFormValid)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Modifier le chargement")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
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
        }
    }
}

#Preview {
    let sampleAmmo = Ammunition(
        name: "Federal Match 168",
        projectileManufacturer: "Federal",
        projectileWeightGrains: 168.0,
        ballisticCoefficient: 0.462,
        dragFunction: 1,
        muzzleVelocityMPS: 808.0,
        muzzleEnergy: 3525.0
    )
    NavigationStack {
        EditAmmunitionView(ammunition: sampleAmmo)
    }
    .modelContainer(for: Ammunition.self, inMemory: true)
}
