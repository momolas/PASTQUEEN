//
//  Gravity.swift
//  PASTQUEEN
//
//  Created by Mo on 31/03/2023.
//

import Foundation
import CoreMotion
import Observation

@MainActor
@Observable
class GravityManager {
	
	var acceleration: CMAcceleration?
	let motionManager = CMMotionManager()
	
	func getGravityData() async throws -> Double {
		try await withTaskCancellationHandler {
			try await withCheckedThrowingContinuation { continuation in
				if motionManager.isDeviceMotionAvailable {
					motionManager.deviceMotionUpdateInterval = 0.1
					var hasResumed = false
					motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
						guard !hasResumed else { return }
						hasResumed = true
						self?.motionManager.stopDeviceMotionUpdates()

						if let error = error {
							continuation.resume(throwing: error)
							return
						}
						if let gravity = motion?.gravity {
							let g = sqrt(pow(gravity.x, 2) + pow(gravity.y, 2) + pow(gravity.z, 2))
							continuation.resume(returning: g)
						} else {
							continuation.resume(throwing: NSError(domain: "com.example.app", code: 2, userInfo: [NSLocalizedDescriptionKey: "No gravity data available"]))
						}
					}
				} else {
					continuation.resume(throwing: NSError(domain: "com.example.app", code: 1, userInfo: [NSLocalizedDescriptionKey: "Device motion is not available"]))
				}
			}
		} onCancel: {
			Task { @MainActor in
				motionManager.stopDeviceMotionUpdates()
			}
		}
	}
}
