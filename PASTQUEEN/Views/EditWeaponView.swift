//
//  EditWeaponView.swift
//  PASTQUEEN
//

import SwiftUI
import SwiftData

struct EditWeaponView: View {
    @Bindable var weapon: Weapon
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
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
                    weapon.name = name
                    weapon.calibre = calibre
                    weapon.sightHeightCM = sightHeightCM
                    weapon.zeroRangeMeters = zeroRangeMeters
                    weapon.scopeClickUnit = scopeClickUnit
                    weapon.twistRateInches = twistRateInches
                    weapon.twistDirection = twistDirection
                    
                    do {
                        try modelContext.save()
                    } catch {
                        print("Failed to save modified weapon: \(error)")
                    }
                    dismiss()
                }
                .disabled(!isFormValid)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Modifier la carabine")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }
        }
        .onAppear {
            name = weapon.name
            calibre = weapon.calibre
            sightHeightCM = weapon.sightHeightCM
            zeroRangeMeters = weapon.zeroRangeMeters
            scopeClickUnit = weapon.scopeClickUnit
            twistRateInches = weapon.twistRateInches
            twistDirection = weapon.twistDirection
        }
    }
}

#Preview {
    let sampleWeapon = Weapon(name: "Savage Axis Varmint", calibre: ".308 Win", sightHeightCM: 4.5, zeroRangeMeters: 100.0)
    NavigationStack {
        EditWeaponView(weapon: sampleWeapon)
    }
    .modelContainer(for: Weapon.self, inMemory: true)
}
