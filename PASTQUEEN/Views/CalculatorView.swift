//
//  SwiftUIView2.swift
//  PASTQUEEN
//
//  Created by Mo on 16/09/2022.
//

import SwiftUI
import CoreData

struct CalculatorView: View {
	let ballisticSettings: BallisticSettings
//	var ballisticCalculator = BallisticCalculator.sharedInstance
//	var weatherData = WeatherData.sharedInstance
	
	var body: some View {
		VStack {
			Text("Bullet Diameter is \(ballisticSettings.ballisticCoefficient)")
			Text("Bullet Weight is \(ballisticSettings.muzzleVelocity)")
			Text("Muzzle Velocity is \(ballisticSettings.muzzleEnergy)")
		}
		.font(.title)
		.foregroundColor(.red)
	}
}

//struct Previews_CalculatorView_Previews: PreviewProvider {
//	static var previews: some View {
//		CalculatorView(ballisticSettings: <#BallisticSettings#>)
//	}
//}
