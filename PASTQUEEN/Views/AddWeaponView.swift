//
//  AddWeaponView.swift
//  PASTQUEEN
//
//  Created by Mo on 27/08/2026.
//

import SwiftUI
import SwiftData

struct AddWeaponView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var calibre: String = ".308 Win"
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
            Section {
                HStack {
                    Label("Nom de la carabine", systemImage: "pencil")
                    Spacer()
                    TextField("Ex: Tikka T3x CTR", text: $name)
                        .multilineTextAlignment(.trailing)
                }

                Picker(selection: $calibre) {
                    ForEach(AmmunitionData.calibers, id: \.self) {
                        Text($0).tag($0)
                    }
                } label: {
                    Label("Calibre", systemImage: "circle.circle")
                }

                HStack {
                    Label("Hauteur de visée", systemImage: "arrow.up.and.down")
                    Spacer()
                    TextField("Hauteur", value: $sightHeightCM, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 70)
                    Text("cm")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("Distance de zérotage", systemImage: "target")
                    Spacer()
                    TextField("Zéro", value: $zeroRangeMeters, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 70)
                    Text("m")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Identification & Zérotage")
            }

            Section {
                HStack {
                    Label("Pas de rayure", systemImage: "tornado")
                    Spacer()
                    Text("1:")
                        .foregroundStyle(.secondary)
                    TextField("Pas", value: $twistRateInches, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 50)
                    Text("pouces")
                        .foregroundStyle(.secondary)
                }

                Picker(selection: $twistDirection) {
                    ForEach(TwistDirection.allCases) { dir in
                        Text(dir.rawValue).tag(dir)
                    }
                } label: {
                    Label("Sens des rayures", systemImage: "arrow.triangle.2.circlepath")
                }
            } header: {
                Text("Canon & Rayures (Balistique ELR)")
            }

            Section {
                Picker(selection: $scopeClickUnit) {
                    ForEach(ScopeClickUnit.allCases) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                } label: {
                    Label("Valeur du clic", systemImage: "dial.low.fill")
                }
            } header: {
                Text("Tourelles de la Lunette")
            }

            Section {
                Button(action: saveWeapon) {
                    Text("Enregistrer la carabine")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(!isFormValid)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Nouvelle Carabine")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
        }
    }

    private func saveWeapon() {
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
        try? modelContext.save()
        dismiss()
    }
}
