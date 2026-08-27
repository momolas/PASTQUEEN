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
    @State private var twistRateInches: Double = 10.0
    @State private var twistDirection: TwistDirection = .right

    private var isFormValid: Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        guard sightHeightCM > 0 else { return false }
        guard zeroRangeMeters > 0 else { return false }
        guard twistRateInches > 0 else { return false }
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

            Section(header: Text("Canon & Rayures (ELR)")) {
                TextField("Pas de rayure (1:X pouces)", value: $twistRateInches, format: .number)
                Picker("Sens des rayures", selection: $twistDirection) {
                    ForEach(TwistDirection.allCases) { dir in
                        Text(dir.rawValue).tag(dir)
                    }
                }
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
                        scopeClickUnit: scopeClickUnit,
                        twistRateInches: twistRateInches,
                        twistDirection: twistDirection
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
