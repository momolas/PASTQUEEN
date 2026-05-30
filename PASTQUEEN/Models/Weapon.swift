//
//  Weapon.swift
//  PASTQUEEN
//

import Foundation
import SwiftData

enum ScopeClickUnit: String, Codable, CaseIterable, Identifiable {
    case moa14 = "1/4 MOA"
    case moa18 = "1/8 MOA"
    case mrad10 = "0.1 MRAD"
    
    var id: String { self.rawValue }

    /// Calculates the number of physical clicks needed for a given MOA correction.
    func clicks(forMOACorrection correctionMOA: Double) -> Int {
        switch self {
        case .moa14:
            return Int(round(abs(correctionMOA) * 4.0))
        case .moa18:
            return Int(round(abs(correctionMOA) * 8.0))
        case .mrad10:
            // 0.1 MRAD is approximately 0.343774677 MOA
            return Int(round(abs(correctionMOA) / 0.343774677))
        }
    }
}

@Model
class Weapon {
    #Index<Weapon>([\.name])

    var id: UUID
    var name: String
    var calibre: String
    var sightHeightCM: Double
    var zeroRangeMeters: Double
    var scopeClickUnit: ScopeClickUnit
    
    @Relationship(deleteRule: .cascade, inverse: \Ammunition.weapon) 
    var ammunitions: [Ammunition]?

    init(id: UUID = UUID(), name: String, calibre: String, sightHeightCM: Double, zeroRangeMeters: Double, scopeClickUnit: ScopeClickUnit = .moa18) {
        self.id = id
        self.name = name
        self.calibre = calibre
        self.sightHeightCM = sightHeightCM
        self.zeroRangeMeters = zeroRangeMeters
        self.scopeClickUnit = scopeClickUnit
        self.ammunitions = []
    }
}
