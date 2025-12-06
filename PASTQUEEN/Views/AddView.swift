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

    @State private var ammunitionData: AmmunitionData?

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    var body: some View {
        NavigationView {
            Form {
                if let ammunitionData = ammunitionData {
                    Section("Ammunition Details") {
                        TextField("Ammunition Name", text: $ammunitionName)
                        TextField("Manufacturer", text: $projectileManufacturer)
                        Picker("Caliber", selection: $calibre) {
                            ForEach(ammunitionData.calibers, id: \.self) {
                                Text($0)
                            }
                        }
                        TextField("Projectile Weight (grains)", value: $projectileWeightGrains, formatter: formatter)
                    }

                    Section("Ballistic Data") {
                        TextField("Ballistic Coefficient", value: $ballisticCoefficient, formatter: formatter)
                        TextField("Muzzle Velocity (m/s)", value: $muzzleVelocityMPS, formatter: formatter)
                        TextField("Muzzle Energy (Joules)", value: $muzzleEnergy, formatter: formatter)
                        Picker("Drag Function", selection: $dragFunction) {
                            ForEach(ammunitionData.dragFunctions) { function in
                                Text(function.name).tag(function.id)
                            }
                        }
                    }

                    Section("Rifle Setup") {
                        TextField("Sight Height (cm)", value: $sightHeightCM, formatter: formatter)
                        TextField("Zero Range (meters)", value: $zeroRangeMeters, formatter: formatter)
                    }

                    Section {
                        Button("Save") {
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
                    }
                } else {
                    Text("Loading ammunition data...")
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
            .onAppear(perform: loadData)
        }
    }

    func loadData() {
        if let url = Bundle.main.url(forResource: "AmmunitionData", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                ammunitionData = try decoder.decode(AmmunitionData.self, from: data)
            } catch {
                print("Error loading ammunition data: \(error)")
            }
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
    }
}
