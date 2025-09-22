//
//  Gravity.swift
//  PASTQUEEN
//
//  Created by Mo on 31/03/2023.
//

import Foundation
import CoreMotion
import Observation

@Observable
class GravityManager: ObservableObject {
	
	var acceleration: CMAcceleration?
	let motionManager = CMMotionManager()
	
	func getGravityData(completion: @escaping (Double?, Error?) -> Void) {
		if motionManager.isDeviceMotionAvailable {
			motionManager.deviceMotionUpdateInterval = 0.1
			motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
				if let gravity = motion?.gravity {
					let g = sqrt(pow(gravity.x, 2) + pow(gravity.y, 2) + pow(gravity.z, 2))
					completion(g, nil)
				} else {
					completion(nil, error)
				}
			}
		} else {
			completion(nil, NSError(domain: "com.example.app", code: 1, userInfo: [NSLocalizedDescriptionKey: "Device motion is not available"]))
		}
	}
}
