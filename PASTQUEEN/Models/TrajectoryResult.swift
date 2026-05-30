//
//  TrajectoryResult.swift
//  PASTQUEEN
//
//  Created by Mo on 30/05/2026.
//

import Foundation

struct TrajectoryResult {
    let distance: Double
    let dropCM: Double
    let dropCorrectionMOA: Double
    let timeSeconds: Double
    let windageCM: Double
    let windageCorrectionMOA: Double
    let velocityMPS: Double
    let energyJoules: Double

    static var empty: TrajectoryResult {
        TrajectoryResult(
            distance: 0,
            dropCM: 0,
            dropCorrectionMOA: 0,
            timeSeconds: 0,
            windageCM: 0,
            windageCorrectionMOA: 0,
            velocityMPS: 0,
            energyJoules: 0
        )
    }
}
