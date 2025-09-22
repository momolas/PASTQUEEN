//
//  TargetPin.swift
//  Ballistics
//
//  Created by Richard Padgett on 1/3/18.
//  Copyright © 2018 Richard-Padgett. All rights reserved.
//

import Foundation
import MapKit

class TargetPin: NSObject, MKAnnotation {
	var markerTintColor: UIColor  {
		switch discipline {
			case "Monument":
				return .red
			case "Mural":
				return .cyan
			case "Target":
				return .blue
			case "Sculpture":
				return .purple
			default:
				return .green
		}
	}
	
	var imageName: String? {
		if discipline == "Sculpture" { return "Statue" }
		return "Flag"
	}
	
	let title: String?
	let locationName: String
	let discipline: String
	let coordinate: CLLocationCoordinate2D
	
	var temperatureFarenheit: Double
	var relativeHumidityPercent: Double
	var altitudeFt: Double
	var windVelocityMiHr: Double
	var windAngleDeg: Double
	var barometricPressureInHg: Double
	
	init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
		self.title = title
		self.locationName = locationName
		self.discipline = discipline
		self.coordinate = coordinate
		
		// set variables to standard values
		self.temperatureFarenheit = 78.6
		self.relativeHumidityPercent = 78.0
		self.altitudeFt = 0.0
		self.windVelocityMiHr = 0
		self.windAngleDeg = 0.0
		
		self.barometricPressureInHg = 0.0
		
		super.init()
		
		// Get specific values
		self.getWeather()
		self.getAltitude()
	}
	
	var subtitle: String? {
		return "Wind: " + String(windAngleDeg) + "\u{00B0}" + //"\n" +
		" " + String(windVelocityMiHr) + "mi/hr" //+ //"\n" +
		//" Hum: " + relativeHumidityPercent + "\u{0025}" + //"\n" +
		//" Temp: " + temperatureFarenheight + "\u{00B0}" + //"\n" +
		//" Alt: " + altitudeFt + "ft" + //"\n" +
		//" Bar: " + barometricPressureInHg + "in/Hg"
	}
	
	func getWeather() {
		let wlat = String(self.coordinate.latitude)
		let wlon = String(self.coordinate.longitude)
		
		let u = "http://api.openweathermap.org/data/2.5/weather"
		let lat = "?lat="
		let lon = "&lon="
		let key = "&&APPID=f876abf1b6b68c7d99b1f283568fb680"
		_ = "&units=imperial"
		
		let OPEN_WEATHER_KEY = ""
		
		let urlWeather = URL(string: u + lat + (wlat) + lon + (wlon) + key + OPEN_WEATHER_KEY)!
		
		//http://api.openweathermap.org/data/2.5/weather?lat=34.67558593&lon=-82.8350379&&APPID=f876abf1b6b68c7d99b1f283568fb680
		
		let weatherData = WeatherController.sharedInstance
		weatherData.setUrl(userLat: String(coordinate.latitude),userLon: String(coordinate.longitude))
		
		let urlRequest = URLRequest(url: urlWeather)
		
		// set up the session
		let config = URLSessionConfiguration.default
		let session = URLSession(configuration: config)
		
		// make the request
		let task = session.dataTask(with: urlRequest) { (data, response, error) in
			// check for any errors
			guard error == nil else {
				print("error calling GET on " + String(describing: urlRequest))
				print(error!)
				return
			}
			// make sure we got data
			guard let responseData = data else {
				print("Error: did not receive weather data")
				return
			}
			// parse the result as JSON, since that's what the API provides
			do {
				guard let weather = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {
					print("error trying to convert weather data to JSON")
					return
				}
				
				self.initVarsWeather(json: weather as [String: AnyObject])
			} catch {
				print("error trying to convert data to JSON")
				self.initInvalidWeather()
				return
			}
		}
		task.resume()
	}
	
	func getAltitude() {
		//        #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
		
		let alat = String(self.coordinate.latitude)
		let alon = String(self.coordinate.longitude)
		
		let alt = "https://maps.googleapis.com/maps/api/elevation/json?locations="
		let sens = "&sensor=false"
		let keyalt = "&key=AIzaSyD8xUQrF94KOD_07X9uciOaC7iTfLO_y_M"
		
		let GOOGLE_ELEVATION_KEY = ""
		
		let urlAltitude = URL(string: alt + alat + "," + alon + sens + keyalt + GOOGLE_ELEVATION_KEY)!
		
		//https://maps.googleapis.com/maps/api/elevation/json?locations=39.7391536,-104.9847034&key=AIzaSyD8xUQrF94KOD_07X9uciOaC7iTfLO_y_M
		
		let urlRequest = URLRequest(url: urlAltitude)
		
		// set up the session
		let config = URLSessionConfiguration.default
		let session = URLSession(configuration: config)
		
		// make the request
		let task = session.dataTask(with: urlRequest) { (data, response, error) in
			
			// check for any errors
			guard error == nil else {
				print("error calling GET on " + String(describing: urlRequest))
				print(error!)
				return
			}
			
			// make sure we got data
			guard let responseData = data else {
				print("Error: did not receive weather data")
				return
			}
			
			// parse the result as JSON, since that's what the API provides
			do {
				guard let weather = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {
					print("error trying to convert weather data to JSON")
					return
				}
				
				self.initVarsAltitude(json: (weather as [String: AnyObject]))
			} catch {
				print("error trying to convert data to JSON")
				self.initInvalidAltitude()
				return
			}
		}
		task.resume()
		
		//        #else
		//            let lat = CLLocationDegrees(Double(self.coordinate.latitude))
		//            let lon = CLLocationDegrees(Double(self.coordinate.longitude))
		//            let location = CLLocation(latitude: lat, longitude: lon)
		//            let elevation = (Double(location.altitude) * 1.09361) * 3
		//            self.altitudeFt = elevation
		//        #endif
	}
	
	func initVarsWeather(json: [String: AnyObject]){
		
		if (json["main"] != nil) {
			if (json["main"]!["humidity"] != nil) {
				self.relativeHumidityPercent = Double(String(describing: json["main"]!["humidity"]!!))!
			} else {
				self.relativeHumidityPercent = 78/100
			}
			
			if (json["main"]!["pressure"] != nil) {
				self.barometricPressureInHg = (Double(String(describing: json["main"]!["pressure"]!!))! * 0.030) // Conversion to Hg
			} else {
				self.barometricPressureInHg = 0
			}
			
			if (json["wind"]!["deg"] != nil && json["wind"] != nil && json["wind"]!["deg"]! != nil) {
				self.windAngleDeg = Double(String(describing: json["wind"]!["deg"]!!))!
			} else {
				self.windAngleDeg = 0
			}
			if (json["wind"]!["deg"] != nil && json["wind"] != nil && json["wind"]!["deg"]! != nil) {
				self.windVelocityMiHr = Double(String(describing: json["wind"]!["speed"]!!))!
			} else {
				self.windVelocityMiHr = 0
			}
			if (json["main"]!["temp"] != nil) {
				let str = (String(describing: json["main"]!["temp"]!!))
				let kelvin = Double(str)
				let rankin = kelvin! * 9/5
				//  let celcius = rankin * 9/5 - 273.15
				let farenheit = rankin - 459.67
				let far = String(format:"%.2f",farenheit)
				//  let cel = String(format:"%.2f",celcius)
				self.temperatureFarenheit = Double(far)!
			} else {
				self.temperatureFarenheit = 78.3
			}
		} else {
			initInvalidWeather()
		}
	}
	
	func initInvalidWeather() {
		print("invalid call in weather ")
	}
	
	func initVarsAltitude(json: [String: AnyObject]) {
		let result = json["results"]! as! NSArray
		let array0 = result[0] as! NSDictionary
		var elevation = (array0["elevation"]!) as! Double
		elevation = (elevation * 1.09361) * 3
		self.altitudeFt = elevation
	}
	
	func initInvalidAltitude() {
		print("invalid call in altitude")
	}
}
