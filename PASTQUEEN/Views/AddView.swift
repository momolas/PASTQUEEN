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
    @State private var muzzleVelocity = 0.0
    @State private var muzzleEnergy = 0.0
    @State private var calibre: String = ".308"
    @State private var projectileWeight: Int32 = 168
    @State private var sightHeight: Double = 1.5
    @State private var zeroRange: Double = 100.0
    @State private var dragFunction: Int32 = 1
    @State private var projectileManufacturer: String = ""

    let calibers = [".308", ".22LR", ".223", "6.5CM", "9mm"]
    let dragFunctions = [1, 2, 5, 6, 7, 8] // G1, G2, G5, G6, G7, G8

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    var body: some View {
        NavigationView {
            Form {
                Section("Ammunition Details") {
                    TextField("Ammunition Name", text: $ammunitionName)
                    TextField("Manufacturer", text: $projectileManufacturer)
                    Picker("Caliber", selection: $calibre) {
                        ForEach(calibers, id: \.self) {
                            Text($0)
                        }
                    }
                    TextField("Projectile Weight (grains)", value: $projectileWeight, formatter: formatter)
                }

                Section("Ballistic Data") {
                    TextField("Ballistic Coefficient", value: $ballisticCoefficient, formatter: formatter)
                    TextField("Muzzle Velocity (ft/s)", value: $muzzleVelocity, formatter: formatter)
                    TextField("Muzzle Energy (ft-lbs)", value: $muzzleEnergy, formatter: formatter)
                    Picker("Drag Function", selection: $dragFunction) {
                        ForEach(dragFunctions, id: \.self) {
                            Text("G\($0)")
                        }
                    }
                }

                Section("Rifle Setup") {
                    TextField("Sight Height (inches)", value: $sightHeight, formatter: formatter)
                    TextField("Zero Range (yards)", value: $zeroRange, formatter: formatter)
                }

                Section {
                    Button("Save") {
                        let newAmmunition = Ballistics(
                            ammunitionName: ammunitionName,
                            ballisticCoefficient: ballisticCoefficient,
                            calibre: calibre,
                            date: Date().timeIntervalSince1970,
                            distanceYards: 0, // This will be set in the calculator view
                            dragFunction: dragFunction,
                            id: UUID(),
                            muzzleEnergy: muzzleEnergy,
                            muzzleVelocity: muzzleVelocity,
                            projectileManufacturer: projectileManufacturer,
                            projectileWeight: projectileWeight,
                            sightHeight: sightHeight,
                            zeroRange: zeroRange
                        )
                        modelContext.insert(newAmmunition)
                        dismiss()
                    }
                }
            }
            .navigationBarTitle("Add Ammunition", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
    }
}