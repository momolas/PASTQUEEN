//
//  SwiftUIView2.swift
//  PASTQUEEN
//
//  Created by Mo on 16/09/2022.
//

import SwiftUI
import CoreData

struct CalculatorView: View {
	let ballisticSettings: Ballistics
//	var ballisticCalculator = BallisticCalculator.sharedInstance
//	var weatherData = WeatherData.sharedInstance
	
	var body: some View {
		VStack {
			Text("Bullet Diameter is \(ballisticSettings.calibre)")
			Text("Bullet Weight is \(ballisticSettings.projectileWeight)")
			Text("Muzzle Velocity is \(ballisticSettings.muzzleVelocity)")
		}
		.font(.title)
		.foregroundColor(.red)
	}
}

struct Previews_CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        let previewBallistics = Ballistics(
            ammunitionName: "Preview Ammo",
            ballisticCoefficient: 0.45,
            calibre: ".308",
            date: Date().timeIntervalSince1970,
            distanceYards: 100.0,
            dragFunction: 1,
            id: UUID(),
            muzzleEnergy: 2600.0,
            muzzleVelocity: 2800.0,
            projectileManufacturer: "Preview Manufacturer",
            projectileWeight: 168,
            sightHeight: 1.5,
            zeroRange: 100.0
        )
        CalculatorView(ballisticSettings: previewBallistics)
    }
}
