//
//  Ammunition.swift
//  PASTQUEEN
//

import Foundation
import SwiftData

@Model
class Ammunition {
    #Index<Ammunition>([\.date], [\.name])

    var id: UUID
    var name: String
    var projectileManufacturer: String
    var projectileWeightGrains: Double
    var ballisticCoefficient: Double
    var dragFunction: Int32
    var muzzleVelocityMPS: Double
    var muzzleEnergy: Double
    var date: Double
    
    var weapon: Weapon?

    init(id: UUID = UUID(), name: String, projectileManufacturer: String, projectileWeightGrains: Double, ballisticCoefficient: Double, dragFunction: Int32, muzzleVelocityMPS: Double, muzzleEnergy: Double, date: Double = Date().timeIntervalSince1970) {
        self.id = id
        self.name = name
        self.projectileManufacturer = projectileManufacturer
        self.projectileWeightGrains = projectileWeightGrains
        self.ballisticCoefficient = ballisticCoefficient
        self.dragFunction = dragFunction
        self.muzzleVelocityMPS = muzzleVelocityMPS
        self.muzzleEnergy = muzzleEnergy
        self.date = date
    }
}
