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

    /// Calculates the MOA correction for a given number of clicks.
    func moaCorrection(forClicks clicks: Int) -> Double {
        switch self {
        case .moa14:
            return Double(clicks) * 0.25
        case .moa18:
            return Double(clicks) * 0.125
        case .mrad10:
            return Double(clicks) * 0.343774677
        }
    }
}


enum TwistDirection: String, Codable, CaseIterable, Identifiable {
    case right = "Right (RH)"
    case left = "Left (LH)"
    
    var id: String { self.rawValue }
}

@Model
class Weapon {
    #Index<Weapon>([\.name])

    var id: UUID = UUID()
    var name: String = ""
    var calibre: String = ""
    var sightHeightCM: Double = 3.81
    var zeroRangeMeters: Double = 100.0
    var scopeClickUnit: ScopeClickUnit = ScopeClickUnit.moa18
    var twistRateInches: Double = 10.0
    var twistDirection: TwistDirection = TwistDirection.right
    
    @Relationship(deleteRule: .cascade, inverse: \Ammunition.weapon) 
    var ammunitions: [Ammunition]?


    init(
        id: UUID = UUID(),
        name: String,
        calibre: String,
        sightHeightCM: Double,
        zeroRangeMeters: Double,
        scopeClickUnit: ScopeClickUnit = .moa18,
        twistRateInches: Double = 10.0,
        twistDirection: TwistDirection = .right
    ) {
        self.id = id
        self.name = name
        self.calibre = calibre
        self.sightHeightCM = sightHeightCM
        self.zeroRangeMeters = zeroRangeMeters
        self.scopeClickUnit = scopeClickUnit
        self.twistRateInches = twistRateInches
        self.twistDirection = twistDirection
        self.ammunitions = []
    }
}

