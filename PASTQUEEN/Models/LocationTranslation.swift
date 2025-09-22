//
//  LocationTranslation.swift
//  Ballistics
//
//  Created by Richard Padgett on 1/9/18.
//  Copyright © 2018 Richard-Padgett. All rights reserved.
//

import Foundation
import MapKit

public extension CLLocationCoordinate2D {
    
    struct Constant {
        static let earthRadius : Double = 6378.14 //km
    }
    
    func DegtoRad(deg: Double) -> Double {
        return deg * Double.pi / 180
    }
    
    func RadtoDeg(rad: Double) -> Double {
        return rad * 180 / Double.pi
    }
    
    func translate(bearing: CLLocationDirection, distanceKm: Double) -> CLLocationCoordinate2D {
        let ballisticsCalculator = BallisticCalculator.sharedInstance
        let angleCorrection = ballisticsCalculator.angleCorrection
        
        let bearingDouble = DegtoRad(deg: Double(bearing))
        
        let lat1 = DegtoRad(deg: Double(self.latitude))
        let lon1 = DegtoRad(deg: Double(self.longitude))
        
        var lat2 : CLLocationDegrees = 0
        var lon2 : CLLocationDegrees = 0
        
        var projectedDistance : Double = 0
        
        var controlDistance = distanceKm
        var checkVar : Double = 1000
        
        var calcs = 0
        
        var alt : Double = 0
        
        while(checkVar > 0.000000001) {
            let radlat2 = asin(sin(lat1) * cos(controlDistance / Constant.earthRadius) + cos(lat1) * sin(controlDistance / Constant.earthRadius) * cos(bearingDouble))
        
            let radlon2 = lon1 + atan2(sin(bearingDouble) * sin(controlDistance / Constant.earthRadius) * cos(lat1), cos(controlDistance / Constant.earthRadius) - sin(lat1) * sin(radlat2))
        
            lat2 = RadtoDeg(rad: radlat2)
            lon2 = RadtoDeg(rad: radlon2)
        
            projectedDistance = Double(CLLocation(latitude: self.latitude, longitude: self.longitude).distance(from: CLLocation(latitude: lat2, longitude: lon2)))
            projectedDistance = projectedDistance * 0.001

            //checkVar = distanceKm - projectedDistance
            
            //Compute distance as hypotenuse
            if (angleCorrection) {
                
				#if targetEnvironment(simulator)
                    
                    getAltitude(latitude: lat2, longitude: lon2)

                    let w = WeatherData.sharedInstance
                    let tAlt = w.targetAltitude
                    let sAlt = w.altitude
                    projectedDistance = getHypotenuse(shooterHeight: sAlt, targetHeight: tAlt, shotDistance: projectedDistance * 0.0009144)
                    projectedDistance = (projectedDistance / 0.0009144)
                    checkVar = distanceKm - projectedDistance
                    
                #else
                
                    let targetLocation = CLLocation(latitude: lat2, longitude: lon2)
                    let targetAltitude = ((targetLocation.altitude  * 1.09361) * 3)
                    let shooterLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
                    let shooterAltitude = ((shooterLocation.altitude * 1.09361) * 3)
                    let currentDistance = projectedDistance * 0.0009144
                    projectedDistance = getHypotenuse(shooterHeight: shooterAltitude, targetHeight: targetAltitude, shotDistance: currentDistance)
                    projectedDistance = (projectedDistance / 0.0009144)
                    checkVar = distanceKm - projectedDistance
                
                #endif
            } else {
				//Compute flat distance
                checkVar = distanceKm - projectedDistance
            }
            
          //  print(checkVar)
            
            if (projectedDistance < distanceKm) {
                controlDistance = controlDistance + 0.0000001
            }
            
			if (projectedDistance > distanceKm) {
                controlDistance = controlDistance - 0.0000001
            }
        }
        
		let test = CLLocation(latitude: self.latitude, longitude: self.longitude)
        
        print(test.altitude)
        
        return CLLocationCoordinate2D(latitude: lat2, longitude: lon2)
    }
    
    // Set shot angle based on elevations of target and shooter
    func getHypotenuse(shooterHeight: Double, targetHeight: Double, shotDistance: Double) -> Double {
        var shotAngle : Double = 0
        var distance = shotDistance
        var opposite : Double = 0
        var hypotenuse : Double = 0
        
     
        // Shooting Downhill
        if (targetHeight > shooterHeight) {
            opposite = (targetHeight - shooterHeight)
            
            hypotenuse = sqrt(pow(shotDistance, 2) + pow(opposite, 2))
            
            if (hypotenuse > shotDistance) {
                distance = hypotenuse
                shotAngle = asin(opposite / distance)
                shotAngle = RadtoDeg(rad: shotAngle)
            } else {
                shotAngle = atan(opposite / distance)
                shotAngle = RadtoDeg(rad: shotAngle)
            }
        } else {
			// Shooting Uphill
			opposite = (shooterHeight - targetHeight)
            
            hypotenuse = sqrt(pow(distance, 2) + pow(opposite, 2))
            
            if (hypotenuse > distance) {
                distance = hypotenuse
                shotAngle = -(asin(opposite / distance))
                shotAngle = RadtoDeg(rad: shotAngle)
            } else {
                shotAngle = -(atan(opposite / distance))
                shotAngle = RadtoDeg(rad: shotAngle)
            }
        }
        return distance
    }
    
    func getAltitude(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        var elevation : Double = 0
        let alat = String(latitude)
        let alon = String(longitude)
        
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
                
				let w = WeatherData.sharedInstance
                let json = weather as [String : AnyObject]
                let result = json["results"]! as! NSArray
                let array0 = result[0] as! NSDictionary
                elevation = (array0["elevation"]!) as! Double
                w.targetAltitude = (elevation * 1.09361) * 3
            } catch {
                print("error trying to convert data to JSON")
                //self.initInvalidAltitude()
                return
            }
        }
        task.resume()
    }
}
