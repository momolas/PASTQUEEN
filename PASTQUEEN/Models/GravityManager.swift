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
	private var activeContinuation: CheckedContinuation<Double, any Error>?
	
	func getGravityData() async throws -> Double {
		cancelActiveUpdates()
		
		return try await withTaskCancellationHandler {
			try await withCheckedThrowingContinuation { continuation in
				guard motionManager.isDeviceMotionAvailable else {
					continuation.resume(throwing: NSError(domain: "com.example.app", code: 1, userInfo: [NSLocalizedDescriptionKey: "Device motion is not available"]))
					return
				}
				
				self.activeContinuation = continuation
				motionManager.deviceMotionUpdateInterval = 0.1
				motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
					guard let self = self else { return }
					guard let continuation = self.activeContinuation else { return }
					self.activeContinuation = nil
					self.motionManager.stopDeviceMotionUpdates()

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
			}
		} onCancel: {
			Task { @MainActor in
				self.cancelActiveUpdates()
			}
		}
	}
	
	private func cancelActiveUpdates() {
		motionManager.stopDeviceMotionUpdates()
		if let continuation = activeContinuation {
			activeContinuation = nil
			continuation.resume(throwing: CancellationError())
		}
	}
}
