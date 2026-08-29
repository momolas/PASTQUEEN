//
//  Weapon.swift
//  PASTQUEEN
//

import Foundation
import SwiftData
import Ballistics

enum ScopeClickUnit: String, Codable, CaseIterable, Identifiable {
    case moa14 = "1/4 MOA"
    case moa18 = "1/8 MOA"
    case mrad10 = "0.1 MRAD"
    
    var id: String { self.rawValue }

    /// Bridge to swift-ballistics TurretClick specification
    var turretClick: TurretClick {
        switch self {
        case .moa14: return .oneFourthMOA
        case .moa18: return .oneEighthMOA
        case .mrad10: return .pointOneMRAD
        }
    }

    /// Calculates the number of physical clicks needed for a given MOA correction.
    func clicks(forMOACorrection correctionMOA: Double) -> Int {
        abs(turretClick.clicks(for: Measurement(value: correctionMOA, unit: .minutesOfAngle)))
    }

    /// Calculates the MOA correction for a given number of clicks.
    func moaCorrection(forClicks clicks: Int) -> Double {
        let singleClickMOA = turretClick.angleValue.converted(to: .minutesOfAngle).value
        return Double(clicks) * singleClickMOA
    }
}

extension TwistDirection: @retroactive Identifiable {
    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .right: return "Droitier (RH)"
        case .left: return "Gaucher (LH)"
        }
    }
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

