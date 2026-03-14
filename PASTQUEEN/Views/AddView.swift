//
//  AddView.swift
//  PASTQUEEN
//
//  Created by Mo on 26/10/2022.
//

import SwiftUI
import SwiftData

struct AddView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var ammunitionName = ""
    @State private var ballisticCoefficient = 0.0
    @State private var muzzleVelocityMPS = 0.0
    @State private var muzzleEnergy = 0.0
    @State private var calibre: String = ".308"
    @State private var projectileWeightGrains: Double = 168
    @State private var sightHeightCM: Double = 3.81
    @State private var zeroRangeMeters: Double = 100.0
    @State private var dragFunction: Int32 = 1
    @State private var projectileManufacturer: String = ""

    private var isFormValid: Bool {
        guard !ammunitionName.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        guard !projectileManufacturer.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        guard ballisticCoefficient > 0 else { return false }
        guard muzzleVelocityMPS > 0 else { return false }
        guard muzzleEnergy > 0 else { return false }
        guard projectileWeightGrains > 0 else { return false }
        return true
    }

    var body: some View {
        NavigationView {
            Form {
                Section(.ammunitionDetails) {
                    TextField(String(localized: .ammunitionName), text: $ammunitionName)
                    TextField(String(localized: .manufacturer), text: $projectileManufacturer)
                    Picker(.caliber, selection: $calibre) {
                        ForEach(AmmunitionData.calibers, id: \.self) {
                            Text($0)
                        }
                    }
                    TextField(String(localized: .projectileWeightGrains), value: $projectileWeightGrains, format: .number)
                }

                Section(.ballisticData) {
                    TextField(String(localized: .ballisticCoefficient), value: $ballisticCoefficient, format: .number)
                    TextField(String(localized: .muzzleVelocity), value: $muzzleVelocityMPS, format: .number)
                    TextField(String(localized: .muzzleEnergy), value: $muzzleEnergy, format: .number)
                    Picker(.dragFunction, selection: $dragFunction) {
                        ForEach(AmmunitionData.dragFunctions) { function in
                            Text(function.name).tag(function.id)
                        }
                    }
                }

                Section(.rifleSetup) {
                    TextField(String(localized: .sightHeight), value: $sightHeightCM, format: .number)
                    TextField(String(localized: .zeroRange), value: $zeroRangeMeters, format: .number)
                }

                Section {
                    Button(.save) {
                        let newAmmunition = BallisticSettings(
                            ammunitionName: ammunitionName,
                            ballisticCoefficient: ballisticCoefficient,
                            calibre: calibre,
                            date: Date().timeIntervalSince1970,
                            distanceMeters: 0,
                            dragFunction: dragFunction,
                            id: UUID(),
                            muzzleEnergy: muzzleEnergy,
                            muzzleVelocityMPS: muzzleVelocityMPS,
                            projectileManufacturer: projectileManufacturer,
                            projectileWeightGrains: projectileWeightGrains,
                            sightHeightCM: sightHeightCM,
                            zeroRangeMeters: zeroRangeMeters
                        )
                        modelContext.insert(newAmmunition)
                        dismiss()
                    }
                    .disabled(!isFormValid)
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
}

#Preview {
    do {
        let container = try ModelContainer(for: BallisticSettings.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        return AddView()
            .modelContainer(container)
    } catch {
        return Text("Failed to create container: \(error.localizedDescription)")
    }
}
