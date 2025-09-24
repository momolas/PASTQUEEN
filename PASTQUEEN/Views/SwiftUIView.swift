//
//  SwiftUIView.swift
//  PASTQUEEN
//
//  Created by Mo on 31/03/2023.
//

import SwiftUI

struct SwiftUIView: View {
	
	var weatherManager = WeatherManager()
	var locationManager = LocationManager()
	var gravityManager = GravityManager()
	
	var body: some View {
		Form {
			if let currentWeather = weatherManager.currentWeather {
				Section {
					Label(currentWeather.temperature.converted(to: .celsius).formatted(), systemImage: "thermometer")
					Label("\((currentWeather.humidity * 100).formatted()) %", systemImage: "humidity.fill")
					Label(currentWeather.pressure.converted(to: .hectopascals).formatted(), systemImage: "barometer")
					Label(currentWeather.wind.speed.converted(to: .kilometersPerHour).formatted(), systemImage: "wind")
					Label(currentWeather.wind.direction.converted(to: .degrees).formatted(), systemImage: "safari")
					Label("\((locationManager.userLocation!.altitude.formatted())) m", systemImage: "mountain.2")
					Label(currentWeather.isDaylight ? "Day time" : "Night time", systemImage: currentWeather.isDaylight ? "sun.max.fill" : "moon.stars.fill")
				} header: {
					HStack {
						Spacer()
						Image(systemName: currentWeather.symbolName)
							.font(.system(size: 60))
						Spacer()
					}
				}
			}
			
			Section {
				Button {
					loadCurrentWeatherData()
				} label: {
					Text("Fetch current weather")
				}
				.buttonStyle(.borderedProminent)
			}
		}
		.onAppear(perform: UserCurrentLocationWeather)
	}
	
	func UserCurrentLocationWeather() {
		locationManager.requestPermission()
		locationManager.locationManager.requestLocation()
		
		guard let userLocation = locationManager.userLocation else { return }
		Task.detached { @MainActor in
			await weatherManager.updateCurrentWeather(userLocation: userLocation)
		}
	}
	
	func loadUserCurrentLocation() {
		locationManager.requestPermission()
		locationManager.locationManager.requestLocation()
	}
	
	func loadCurrentWeatherData() {
		guard let userLocation = locationManager.userLocation else { return }
		Task.detached { @MainActor in
			await weatherManager.updateCurrentWeather(userLocation: userLocation)
		}
	}
}

#Preview {
	SwiftUIView()
}
