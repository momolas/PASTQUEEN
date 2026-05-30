//
//  AddWeaponView.swift
//  PASTQUEEN
//

import SwiftUI
import SwiftData

struct AddWeaponView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var calibre: String = ".308"
    @State private var sightHeightCM: Double = 3.81
    @State private var zeroRangeMeters: Double = 100.0
    @State private var scopeClickUnit: ScopeClickUnit = .moa18

    private var isFormValid: Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        guard sightHeightCM > 0 else { return false }
        guard zeroRangeMeters > 0 else { return false }
        return true
    }

    var body: some View {
        Form {
            Section(.rifleSetup) {
                TextField(String(localized: .rifleName), text: $name)
                Picker(String(localized: .caliber), selection: $calibre) {
                    ForEach(AmmunitionData.calibers, id: \.self) {
                        Text($0)
                    }
                }
                TextField(String(localized: .sightHeight), value: $sightHeightCM, format: .number)
                TextField(String(localized: .zeroRange), value: $zeroRangeMeters, format: .number)
            }

            Section(header: Text(.turretCalibration)) {
                Picker(selection: $scopeClickUnit) {
                    ForEach(ScopeClickUnit.allCases) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                } label: {
                    Text(.scopeClickUnit)
                }
            }

            Section {
                Button(.save) {
                    let newWeapon = Weapon(
                        name: name,
                        calibre: calibre,
                        sightHeightCM: sightHeightCM,
                        zeroRangeMeters: zeroRangeMeters,
                        scopeClickUnit: scopeClickUnit
                    )
                    modelContext.insert(newWeapon)
                    do {
                        try modelContext.save()
                    } catch {
                        print("Failed to save context after inserting weapon: \(error)")
                    }
                    dismiss()
                }
                .disabled(!isFormValid)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text(.addWeapon))
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
    AddWeaponView()
        .modelContainer(for: Weapon.self, inMemory: true)
}
