//
//  BallisticSettings.swift
//  PASTQUEEN
//
//  Created by Mo on 22/06/2023.
//
//

import Foundation
import SwiftData

@Model
class Ballistics {
    var ammunitionName: String
    var ballisticCoefficient: Double
    var calibre: String
    var date: Double
    var distanceMeters: Double
    var dragFunction: Int32
    var id: UUID
    var muzzleEnergy: Double
    var muzzleVelocityMPS: Double
    var projectileManufacturer: String
    var projectileWeightGrains: Double
    var sightHeightCM: Double
    var zeroRangeMeters: Double

    init(ammunitionName: String, ballisticCoefficient: Double, calibre: String, date: Double, distanceMeters: Double, dragFunction: Int32, id: UUID, muzzleEnergy: Double, muzzleVelocityMPS: Double, projectileManufacturer: String, projectileWeightGrains: Double, sightHeightCM: Double, zeroRangeMeters: Double) {
        self.ammunitionName = ammunitionName
        self.ballisticCoefficient = ballisticCoefficient
        self.calibre = calibre
        self.date = date
        self.distanceMeters = distanceMeters
        self.dragFunction = dragFunction
        self.id = id
        self.muzzleEnergy = muzzleEnergy
        self.muzzleVelocityMPS = muzzleVelocityMPS
        self.projectileManufacturer = projectileManufacturer
        self.projectileWeightGrains = projectileWeightGrains
        self.sightHeightCM = sightHeightCM
        self.zeroRangeMeters = zeroRangeMeters
    }
}
