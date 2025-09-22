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
    var distanceYards: Double
    var dragFunction: Int32
    var id: UUID
    var muzzleEnergy: Double
    var muzzleVelocity: Double
    var projectileManufacturer: String
    var projectileWeight: Int32
    var sightHeight: Double
    var zeroRange: Double
	
	init(ammunitionName: String, ballisticCoefficient: Double, calibre: String, date: Double, distanceYards: Double, dragFunction: Int32, id: UUID, muzzleEnergy: Double, muzzleVelocity: Double, projectileManufacturer: String, projectileWeight: Int32, sightHeight: Double, zeroRange: Double) {
		self.ammunitionName = ammunitionName
		self.ballisticCoefficient = ballisticCoefficient
		self.calibre = calibre
		self.date = date
		self.distanceYards = distanceYards
		self.dragFunction = dragFunction
		self.id = id
		self.muzzleEnergy = muzzleEnergy
		self.muzzleVelocity = muzzleVelocity
		self.projectileManufacturer = projectileManufacturer
		self.projectileWeight = projectileWeight
		self.sightHeight = sightHeight
		self.zeroRange = zeroRange
	}
}
