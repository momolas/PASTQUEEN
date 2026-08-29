//
//  Ammunition.swift
//  PASTQUEEN
//

import Foundation
import SwiftData

@Model
class Ammunition {
    #Index<Ammunition>([\.date], [\.name], [\.projectileManufacturer])

    var id: UUID = UUID()
    var name: String = ""
    var projectileManufacturer: String = ""
    var projectileWeightGrains: Double = 0.0
    var ballisticCoefficient: Double = 0.0
    var dragFunction: Int32 = 1
    var muzzleVelocityMPS: Double = 0.0
    var muzzleEnergy: Double = 0.0
    var date: Double = 0.0
    var powderSensitivityMPSPerC: Double = 0.0
    
    var weapon: Weapon?

    init(
        id: UUID = UUID(),
        name: String,
        projectileManufacturer: String,
        projectileWeightGrains: Double,
        ballisticCoefficient: Double,
        dragFunction: Int32,
        muzzleVelocityMPS: Double,
        muzzleEnergy: Double,
        powderSensitivityMPSPerC: Double = 0.0,
        date: Double = Date().timeIntervalSince1970
    ) {
        self.id = id
        self.name = name
        self.projectileManufacturer = projectileManufacturer
        self.projectileWeightGrains = projectileWeightGrains
        self.ballisticCoefficient = ballisticCoefficient
        self.dragFunction = dragFunction
        self.muzzleVelocityMPS = muzzleVelocityMPS
        self.muzzleEnergy = muzzleEnergy
        self.powderSensitivityMPSPerC = powderSensitivityMPSPerC
        self.date = date
    }
}


