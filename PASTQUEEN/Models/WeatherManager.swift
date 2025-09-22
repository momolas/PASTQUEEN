//
//  WeatherData.swift
//  PASTQUEEN
//
//  Created by Mo on 31/03/2023.
//

import Foundation
import WeatherKit
import CoreLocation
import Observation

@Observable
class WeatherManager: ObservableObject {
    
    var currentWeather: CurrentWeather?
    let weatherService = WeatherService()
    
    func updateCurrentWeather(userLocation: CLLocation) async {
        do {
            let forecast = try await weatherService.weather(for: userLocation, including: .current)
            DispatchQueue.main.async {
                print(forecast)
                self.currentWeather = forecast
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
