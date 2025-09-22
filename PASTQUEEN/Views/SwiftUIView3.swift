//
//  SwiftUIView3.swift
//  PASTQUEEN
//
//  Created by Mo on 01/11/2023.
//

import SwiftUI

struct SwiftUIView3: View {
	
	var weatherManager = WeatherManager()
	var locationManager = LocationManager()
	var gravityManager = GravityManager()
	var ballisticManager: BallisticManager {
		BallisticManager(
			distanceOfInterest: distanceOfInterest,
			muzzleVelocity: muzzleVelocity,
			bulletWeight: bulletWeight,
			ballisticCoefficient: ballisticCoefficient,
			windSpeed: windSpeed,
			windDirection: windDirection,
			temperature: temperature,
			altitude: altitude,
			pressure: pressure,
			scopeHeight: scopeHeight,
			zeroRange: zeroRange
		)
	}
	
	@State private var distanceOfInterest: Double = 200
	@State private var muzzleVelocity: Double = 2820
	@State private var bulletWeight: Double = 120
	@State private var ballisticCoefficient: Double = 0.297
	@State private var windSpeed: Double = 0.0
	@State private var windDirection: Double = 0.0
	@State private var temperature: Double = 65
	@State private var altitude: Double = 0.0
	@State private var pressure: Double = 1000
	@State private var scopeHeight: Double = 2.0
	@State private var zeroRange: Double = 100
	
//	let currentWeather = weatherManager.currentWeather {
//		var temperature = currentWeather.temperature.converted(to: .celsius).description
//		Label("\((currentWeather.humidity * 100).description) %", systemImage: "humidity.fill")
//		Label(currentWeather.pressure.converted(to: .hectopascals).description, systemImage: "barometer")
//		Label(currentWeather.wind.speed.converted(to: .kilometersPerHour).description, systemImage: "wind")
//		Label(currentWeather.wind.direction.converted(to: .degrees).description, systemImage: "safari")
//		Label("\((locationManager.userLocation!.altitude.formatted())) m", systemImage: "mountain.2")
//		Label(currentWeather.isDaylight ? "Day time" : "Night time", systemImage: currentWeather.isDaylight ? "sun.max.fill" : "moon.stars.fill")
//	}
		
	var body: some View {
		NavigationView {
			Form {
				Section("Paramètres du tir") {
					Stepper(value: $distanceOfInterest, in: 100...1000, label: {
						Text("Distance of interest: \(distanceOfInterest.formatted()) m")
					})
					Stepper(value: $muzzleVelocity, in: 1000...10000, label: {
						Text("Muzzle velocity: \(muzzleVelocity.formatted()) m/s")
					})
					Stepper(value: $bulletWeight, in: 10...100, label: {
						Text("Bullet weight: \(bulletWeight.formatted()) gr")
					})
					Stepper(value: $ballisticCoefficient, in: 0.01...0.5, label: {
						Text("Ballistic coefficient: \(ballisticCoefficient.formatted())")
					})
					Stepper(value: $windSpeed, in: 0...50, label: {
						Text("Wind speed: \(windSpeed.formatted()) km/h")
					})
					Stepper(value: $windDirection, in: 0...360, label: {
						Text("Wind direction: \(windDirection.formatted()) °")
					})
					Stepper(value: $temperature, in: 0...100, label: {
						Text("Temperature: \(temperature.formatted()) °C")
					})
					Stepper(value: $altitude, in: 0...10000, label: {
						Text("Altitude: \(altitude.formatted()) m")
					})
					Stepper(value: $pressure, in: 500...3000, label: {
						Text("Pressure: \(pressure.formatted()) bar")
					})
					Stepper(value: $scopeHeight, in: 0...10, label: {
						Text("Scope height: \(zeroRange.formatted()) cm")
					})
					Stepper(value: $zeroRange, in: 0...1000, label: {
						Text("Zero range: \(zeroRange.formatted()) m")
					})
				}
				
				Section("Données du tir") {
					Text("Élévation MOA: \(ballisticManager.elevationMOA)")
					Text("Dérive MOA: \(ballisticManager.windageMOA)")

					Text("Élévation Click: \(ballisticManager.elevationClick)")
					Text("Dérive Click: \(ballisticManager.windageClick)")
					
					Text("Vitesse du projectile: \(ballisticManager.impactSpeed.formatted()) m/s")
					Text("Énergie du projectile: \(ballisticManager.energy.formatted()) KJ")
					Text("Temps de vol: \(ballisticManager.timeOfFlight) s")
				}
			}
			.navigationBarTitle("Trajectory calculator")
		}
	}
}

#Preview {
	SwiftUIView3()
}
