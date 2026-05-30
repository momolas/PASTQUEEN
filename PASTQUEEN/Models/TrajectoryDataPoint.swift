//
//  TrajectoryDataPoint.swift
//  PASTQUEEN
//
//  Created by Mo on 30/05/2026.
//

import Foundation

struct TrajectoryDataPoint: Identifiable {
    let id = UUID()
    let distance: Double
    let drop: Double
}
