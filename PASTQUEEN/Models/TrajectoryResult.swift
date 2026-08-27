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

    // Advanced ELR components
    let spinDriftCM: Double
    let spinDriftMOA: Double
    let coriolisHorizontalCM: Double
    let coriolisHorizontalMOA: Double
    let coriolisVerticalCM: Double
    let coriolisVerticalMOA: Double
    let aerodynamicJumpCM: Double
    let aerodynamicJumpMOA: Double
    
    // Total corrections (including base + ELR effects)
    let totalDropCM: Double
    let totalDropCorrectionMOA: Double
    let totalWindageCM: Double
    let totalWindageCorrectionMOA: Double

    static var empty: TrajectoryResult {
        TrajectoryResult(
            distance: 0,
            dropCM: 0,
            dropCorrectionMOA: 0,
            timeSeconds: 0,
            windageCM: 0,
            windageCorrectionMOA: 0,
            velocityMPS: 0,
            energyJoules: 0,
            spinDriftCM: 0,
            spinDriftMOA: 0,
            coriolisHorizontalCM: 0,
            coriolisHorizontalMOA: 0,
            coriolisVerticalCM: 0,
            coriolisVerticalMOA: 0,
            aerodynamicJumpCM: 0,
            aerodynamicJumpMOA: 0,
            totalDropCM: 0,
            totalDropCorrectionMOA: 0,
            totalWindageCM: 0,
            totalWindageCorrectionMOA: 0
        )
    }
}

