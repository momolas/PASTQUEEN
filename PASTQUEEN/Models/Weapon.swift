//
//  Weapon.swift
//  PASTQUEEN
//

import Foundation
import SwiftData

@Model
class Weapon {
    var id: UUID
    var name: String
    var calibre: String
    var sightHeightCM: Double
    var zeroRangeMeters: Double
    
    @Relationship(deleteRule: .cascade, inverse: \Ammunition.weapon) 
    var ammunitions: [Ammunition]?

    init(id: UUID = UUID(), name: String, calibre: String, sightHeightCM: Double, zeroRangeMeters: Double) {
        self.id = id
        self.name = name
        self.calibre = calibre
        self.sightHeightCM = sightHeightCM
        self.zeroRangeMeters = zeroRangeMeters
        self.ammunitions = []
    }
}
