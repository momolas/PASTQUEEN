//
//  DetailView.swift
//  PASTQUEEN
//
//  Created by Mo on 26/10/2022.
//

import SwiftUI

struct DetailView: View {
    let ballisticSettings: BallisticSettings
	
//	@Environment(\.managedObjectContext) var managedObjectContext
//	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		Text("BC: " + String(ballisticSettings.ballisticCoefficient))
		Text("Muzzle Velocity: " + String(ballisticSettings.muzzleVelocity) + " m/s")
		Text("Muzzle Energy: " + String(ballisticSettings.muzzleEnergy) + " kJ")
        Text("Projetile Weight: " + String(ballisticSettings.projectileWeight) + " gr")
		
		NavigationLink(destination: CalculatorView(ballisticSettings: ballisticSettings), label: {
			Text("Calculate Range Card")
				.bold()
				.padding()
		})
		.overlay(
			RoundedRectangle(cornerRadius: 10.0)
				.stroke(lineWidth: 2.0)
		)
		.foregroundColor(.blue)
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView()
//    }
//}
