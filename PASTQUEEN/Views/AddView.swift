//
//  AddView.swift
//  PASTQUEEN
//
//  Created by Mo on 26/10/2022.
//

import SwiftUI

struct AddView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	@Environment(\.dismiss) var dismiss
	
	@State private var ammunitionName = ""
	@State private var ballisticCoefficient = ""
	@State private var muzzleVelocity = ""
	@State private var muzzleEnergy = ""
	@State private var caliber: String = ""
	
	let calibers = [".308", ".22LR"]
	
	let formatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		return formatter
	}()
	
	var body: some View {
		NavigationView {
			Form {
				Section {
					TextField("Cartridge Brand", text: $ammunitionName)
					Picker("Caliber", selection: $caliber) {
						ForEach(calibers, id: \.self) {
							Text($0)
						}
					}
					TextField("Ballistic Coefficient", value: $ballisticCoefficient, formatter: formatter)
					TextField("Muzzle Velocity (m/s)", value: $muzzleVelocity, formatter: formatter)
					TextField("Muzzle Energy (kJ)", value: $muzzleEnergy, formatter: formatter)
				}
				
				Section {
					Button(action: {
						let newAmmunition = BallisticSettings(context: managedObjectContext)
						newAmmunition.id = UUID()
						newAmmunition.ammunitionName = ammunitionName
                        newAmmunition.ballisticCoefficient = Double(ballisticCoefficient)!
						newAmmunition.muzzleVelocity = Double(muzzleVelocity)!
						newAmmunition.muzzleEnergy = Double(muzzleEnergy)!
						
						try? managedObjectContext.save()
						dismiss()
					}) {
						Text("Save")
					}
				}
			}
			.navigationBarTitle("Add Ammunition Data")
		}
	}
}

struct AddView_Previews: PreviewProvider {
	static var previews: some View {
		AddView()
	}
}
