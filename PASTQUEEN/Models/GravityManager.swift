//
//  Gravity.swift
//  PASTQUEEN
//
//  Created by Mo on 31/03/2023.
//

import Foundation
import CoreMotion
import Observation

enum GravityError: LocalizedError, Sendable {
    case deviceMotionNotAvailable
    case noGravityDataAvailable
    
    var errorDescription: String? {
        switch self {
        case .deviceMotionNotAvailable:
            return "Device motion is not available"
        case .noGravityDataAvailable:
            return "No gravity data available"
        }
    }
}

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
					continuation.resume(throwing: GravityError.deviceMotionNotAvailable)
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
						let g = sqrt(gravity.x * gravity.x + gravity.y * gravity.y + gravity.z * gravity.z)
						continuation.resume(returning: g)
					} else {
						continuation.resume(throwing: GravityError.noGravityDataAvailable)
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
