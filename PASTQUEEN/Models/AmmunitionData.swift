//
//  AmmunitionData.swift
//  PASTQUEEN
//
//  Created by Jules on 26/10/2025.
//

import Foundation
import Ballistics

enum AmmunitionCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case match = "Match / TLD"
    case hunting = "Chasse"
    case training = "Entraînement / Militaire"
    case subsonic = "Subsonique"

    var id: String { rawValue }
}

struct CatalogAmmunition: Identifiable, Hashable, Sendable, Codable {
    var id: String { "\(manufacturer) \(name) \(caliber)" }
    let manufacturer: String
    let name: String
    let caliber: String
    let projectileWeightGrains: Double
    let ballisticCoefficient: Double
    let dragFunction: Int32
    let muzzleVelocityMPS: Double
    let muzzleEnergyJoules: Double
    let powderSensitivityMPSPerC: Double
    let category: AmmunitionCategory
    let bulletType: String
}

typealias MarketAmmunition = CatalogAmmunition

struct CatalogWeapon: Identifiable, Hashable, Sendable, Codable {
    var id: String { "\(manufacturer) \(name) \(caliber)" }
    let manufacturer: String
    let name: String
    let caliber: String
    let twistRateInches: Double
    let twistDirection: TwistDirection
    let sightHeightCM: Double
    let defaultScopeUnit: ScopeClickUnit
    let category: String
}

struct AmmunitionData {
    static let calibers: [String] = [
        ".22 LR",
        ".223 Rem",
        "6mm Creedmoor",
        "6.5 Creedmoor",
        ".308 Win",
        ".30-06",
        ".300 Win Mag",
        ".338 Lapua Mag",
        "9mm Luger"
    ]
    
    static let dragFunctions: [DragFunctionItem] = [
        DragFunctionItem(id: 1, name: "G1"),
        DragFunctionItem(id: 2, name: "G2"),
        DragFunctionItem(id: 5, name: "G5"),
        DragFunctionItem(id: 6, name: "G6"),
        DragFunctionItem(id: 7, name: "G7"),
        DragFunctionItem(id: 8, name: "G8")
    ]
    
    static var commonLoads: [CatalogAmmunition] {
        catalogAmmunitions
    }

    // MARK: - Comprehensive Catalog of Factory Loads
    static let catalogAmmunitions: [CatalogAmmunition] = [
        // ==========================================
        // .22 LR (Percussion Annulaire)
        // ==========================================
        CatalogAmmunition(manufacturer: "CCI", name: "Standard Velocity 40gr", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.120, dragFunction: 1, muzzleVelocityMPS: 326.0, muzzleEnergyJoules: 137.0, powderSensitivityMPSPerC: 0.10, category: .training, bulletType: "Lead Round Nose (LRN)"),
        CatalogAmmunition(manufacturer: "CCI", name: "Mini-Mag HV 36gr CPHP", caliber: ".22 LR", projectileWeightGrains: 36.0, ballisticCoefficient: 0.125, dragFunction: 1, muzzleVelocityMPS: 384.0, muzzleEnergyJoules: 172.0, powderSensitivityMPSPerC: 0.12, category: .hunting, bulletType: "Copper Plated HP"),
        CatalogAmmunition(manufacturer: "CCI", name: "Subsonic HP 40gr", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.115, dragFunction: 1, muzzleVelocityMPS: 320.0, muzzleEnergyJoules: 131.0, powderSensitivityMPSPerC: 0.10, category: .subsonic, bulletType: "Lead Hollow Point"),
        CatalogAmmunition(manufacturer: "ELEY", name: "Match 40gr", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.150, dragFunction: 1, muzzleVelocityMPS: 329.0, muzzleEnergyJoules: 140.0, powderSensitivityMPSPerC: 0.08, category: .match, bulletType: "Flat Nose Lead Match"),
        CatalogAmmunition(manufacturer: "ELEY", name: "Tenex 40gr", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.155, dragFunction: 1, muzzleVelocityMPS: 327.0, muzzleEnergyJoules: 139.0, powderSensitivityMPSPerC: 0.06, category: .match, bulletType: "Tenex EPS Flat Nose"),
        CatalogAmmunition(manufacturer: "ELEY", name: "Club 40gr", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.140, dragFunction: 1, muzzleVelocityMPS: 331.0, muzzleEnergyJoules: 141.0, powderSensitivityMPSPerC: 0.09, category: .training, bulletType: "Round Nose Lead"),
        CatalogAmmunition(manufacturer: "Lapua", name: "Center-X 40gr", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.172, dragFunction: 1, muzzleVelocityMPS: 327.0, muzzleEnergyJoules: 140.0, powderSensitivityMPSPerC: 0.07, category: .match, bulletType: "Match LRN"),
        CatalogAmmunition(manufacturer: "Lapua", name: "Midas+ 40gr", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.172, dragFunction: 1, muzzleVelocityMPS: 327.0, muzzleEnergyJoules: 140.0, powderSensitivityMPSPerC: 0.06, category: .match, bulletType: "Selected Match LRN"),
        CatalogAmmunition(manufacturer: "SK", name: "Long Range Match 40gr", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.172, dragFunction: 1, muzzleVelocityMPS: 337.0, muzzleEnergyJoules: 147.0, powderSensitivityMPSPerC: 0.08, category: .match, bulletType: "Long Range Match LRN"),
        CatalogAmmunition(manufacturer: "SK", name: "Rifle Match 40gr", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.150, dragFunction: 1, muzzleVelocityMPS: 327.0, muzzleEnergyJoules: 140.0, powderSensitivityMPSPerC: 0.08, category: .match, bulletType: "Match LRN"),
        CatalogAmmunition(manufacturer: "RWS", name: "Target Rifle 40gr", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.110, dragFunction: 1, muzzleVelocityMPS: 330.0, muzzleEnergyJoules: 142.0, powderSensitivityMPSPerC: 0.10, category: .training, bulletType: "Lead Round Nose"),
        CatalogAmmunition(manufacturer: "RWS", name: "R50 Match 40gr", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.145, dragFunction: 1, muzzleVelocityMPS: 330.0, muzzleEnergyJoules: 142.0, powderSensitivityMPSPerC: 0.07, category: .match, bulletType: "High Precision Match LRN"),
        CatalogAmmunition(manufacturer: "Federal", name: "Champion 40gr LRN", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.125, dragFunction: 1, muzzleVelocityMPS: 378.0, muzzleEnergyJoules: 185.0, powderSensitivityMPSPerC: 0.12, category: .training, bulletType: "Lead Round Nose"),
        CatalogAmmunition(manufacturer: "Federal", name: "Gold Medal Target 40gr", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.138, dragFunction: 1, muzzleVelocityMPS: 329.0, muzzleEnergyJoules: 140.0, powderSensitivityMPSPerC: 0.08, category: .match, bulletType: "Match LRN"),
        CatalogAmmunition(manufacturer: "Solognac", name: "22 LR Standard Training 40gr", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.125, dragFunction: 1, muzzleVelocityMPS: 325.0, muzzleEnergyJoules: 137.0, powderSensitivityMPSPerC: 0.10, category: .training, bulletType: "Plomb Standard LRN"),
        CatalogAmmunition(manufacturer: "Solognac", name: "22 LR High Velocity 36gr", caliber: ".22 LR", projectileWeightGrains: 36.0, ballisticCoefficient: 0.118, dragFunction: 1, muzzleVelocityMPS: 385.0, muzzleEnergyJoules: 173.0, powderSensitivityMPSPerC: 0.12, category: .hunting, bulletType: "Cuivrée HP"),
        CatalogAmmunition(manufacturer: "Solognac", name: "22 LR Subsonic Hollow Point 40gr", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.115, dragFunction: 1, muzzleVelocityMPS: 315.0, muzzleEnergyJoules: 128.0, powderSensitivityMPSPerC: 0.10, category: .subsonic, bulletType: "Plomb Creux"),
        CatalogAmmunition(manufacturer: "Winchester", name: "Wildcat 40gr LRN", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.125, dragFunction: 1, muzzleVelocityMPS: 380.0, muzzleEnergyJoules: 183.0, powderSensitivityMPSPerC: 0.12, category: .training, bulletType: "Lead Round Nose"),

        // ==========================================
        // .223 Rem / 5.56x45 NATO
        // ==========================================
        CatalogAmmunition(manufacturer: "Federal", name: "Gold Medal Match 69gr Sierra MK", caliber: ".223 Rem", projectileWeightGrains: 69.0, ballisticCoefficient: 0.301, dragFunction: 1, muzzleVelocityMPS: 899.0, muzzleEnergyJoules: 1809.0, powderSensitivityMPSPerC: 0.30, category: .match, bulletType: "Sierra MatchKing BTHP"),
        CatalogAmmunition(manufacturer: "Federal", name: "Gold Medal Match 77gr Sierra MK", caliber: ".223 Rem", projectileWeightGrains: 77.0, ballisticCoefficient: 0.372, dragFunction: 1, muzzleVelocityMPS: 830.0, muzzleEnergyJoules: 1718.0, powderSensitivityMPSPerC: 0.30, category: .match, bulletType: "Sierra MatchKing BTHP"),
        CatalogAmmunition(manufacturer: "Hornady", name: "ELD Match 73gr", caliber: ".223 Rem", projectileWeightGrains: 73.0, ballisticCoefficient: 0.398, dragFunction: 1, muzzleVelocityMPS: 850.0, muzzleEnergyJoules: 1709.0, powderSensitivityMPSPerC: 0.28, category: .match, bulletType: "ELD-Match Polymer Tip"),
        CatalogAmmunition(manufacturer: "Hornady", name: "Frontier 55gr FMJ", caliber: ".223 Rem", projectileWeightGrains: 55.0, ballisticCoefficient: 0.243, dragFunction: 1, muzzleVelocityMPS: 987.0, muzzleEnergyJoules: 1735.0, powderSensitivityMPSPerC: 0.35, category: .training, bulletType: "FMJ Boat Tail"),
        CatalogAmmunition(manufacturer: "Hornady", name: "V-MAX 55gr Varmint", caliber: ".223 Rem", projectileWeightGrains: 55.0, ballisticCoefficient: 0.255, dragFunction: 1, muzzleVelocityMPS: 980.0, muzzleEnergyJoules: 1710.0, powderSensitivityMPSPerC: 0.32, category: .hunting, bulletType: "V-MAX Polymer Tip"),
        CatalogAmmunition(manufacturer: "Norma", name: "Match-223 77gr Sierra", caliber: ".223 Rem", projectileWeightGrains: 77.0, ballisticCoefficient: 0.372, dragFunction: 1, muzzleVelocityMPS: 835.0, muzzleEnergyJoules: 1739.0, powderSensitivityMPSPerC: 0.25, category: .match, bulletType: "Sierra MatchKing HPBT"),
        CatalogAmmunition(manufacturer: "Fiocchi", name: "Exacta 69gr Sierra MatchKing", caliber: ".223 Rem", projectileWeightGrains: 69.0, ballisticCoefficient: 0.301, dragFunction: 1, muzzleVelocityMPS: 890.0, muzzleEnergyJoules: 1773.0, powderSensitivityMPSPerC: 0.30, category: .match, bulletType: "Sierra MatchKing HPBT"),
        CatalogAmmunition(manufacturer: "GGG", name: "GGG 55gr FMJ NATO", caliber: ".223 Rem", projectileWeightGrains: 55.0, ballisticCoefficient: 0.250, dragFunction: 1, muzzleVelocityMPS: 990.0, muzzleEnergyJoules: 1746.0, powderSensitivityMPSPerC: 0.35, category: .training, bulletType: "FMJ M193 NATO"),
        CatalogAmmunition(manufacturer: "GGG", name: "GGG 69gr Sierra MatchKing", caliber: ".223 Rem", projectileWeightGrains: 69.0, ballisticCoefficient: 0.301, dragFunction: 1, muzzleVelocityMPS: 890.0, muzzleEnergyJoules: 1773.0, powderSensitivityMPSPerC: 0.28, category: .match, bulletType: "Sierra MatchKing HPBT"),
        CatalogAmmunition(manufacturer: "GGG", name: "GGG 77gr Sierra MatchKing", caliber: ".223 Rem", projectileWeightGrains: 77.0, ballisticCoefficient: 0.372, dragFunction: 1, muzzleVelocityMPS: 830.0, muzzleEnergyJoules: 1718.0, powderSensitivityMPSPerC: 0.28, category: .match, bulletType: "Sierra MatchKing HPBT"),
        CatalogAmmunition(manufacturer: "IMI Systems", name: "Razor Core 77gr OTM", caliber: ".223 Rem", projectileWeightGrains: 77.0, ballisticCoefficient: 0.372, dragFunction: 1, muzzleVelocityMPS: 840.0, muzzleEnergyJoules: 1760.0, powderSensitivityMPSPerC: 0.25, category: .match, bulletType: "Sierra MatchKing OTM"),

        // ==========================================
        // 6mm Creedmoor
        // ==========================================
        CatalogAmmunition(manufacturer: "Hornady", name: "ELD Match 108gr", caliber: "6mm Creedmoor", projectileWeightGrains: 108.0, ballisticCoefficient: 0.536, dragFunction: 1, muzzleVelocityMPS: 902.0, muzzleEnergyJoules: 2850.0, powderSensitivityMPSPerC: 0.30, category: .match, bulletType: "ELD-Match Polymer Tip"),
        CatalogAmmunition(manufacturer: "Federal", name: "Gold Medal 105gr Berger Hybrid", caliber: "6mm Creedmoor", projectileWeightGrains: 105.0, ballisticCoefficient: 0.530, dragFunction: 1, muzzleVelocityMPS: 915.0, muzzleEnergyJoules: 2855.0, powderSensitivityMPSPerC: 0.28, category: .match, bulletType: "Berger Hybrid OTM"),
        CatalogAmmunition(manufacturer: "Lapua", name: "Scenar 105gr OTM", caliber: "6mm Creedmoor", projectileWeightGrains: 105.0, ballisticCoefficient: 0.472, dragFunction: 1, muzzleVelocityMPS: 890.0, muzzleEnergyJoules: 2697.0, powderSensitivityMPSPerC: 0.25, category: .match, bulletType: "Scenar OTM (GB543)"),

        // ==========================================
        // 6.5 Creedmoor
        // ==========================================
        CatalogAmmunition(manufacturer: "Hornady", name: "ELD Match 140gr", caliber: "6.5 Creedmoor", projectileWeightGrains: 140.0, ballisticCoefficient: 0.646, dragFunction: 1, muzzleVelocityMPS: 826.0, muzzleEnergyJoules: 3087.0, powderSensitivityMPSPerC: 0.35, category: .match, bulletType: "ELD-Match Polymer Tip"),
        CatalogAmmunition(manufacturer: "Hornady", name: "ELD Match 147gr", caliber: "6.5 Creedmoor", projectileWeightGrains: 147.0, ballisticCoefficient: 0.697, dragFunction: 1, muzzleVelocityMPS: 821.0, muzzleEnergyJoules: 3217.0, powderSensitivityMPSPerC: 0.35, category: .match, bulletType: "ELD-Match Polymer Tip"),
        CatalogAmmunition(manufacturer: "Hornady", name: "Precision Hunter 143gr ELD-X", caliber: "6.5 Creedmoor", projectileWeightGrains: 143.0, ballisticCoefficient: 0.625, dragFunction: 1, muzzleVelocityMPS: 823.0, muzzleEnergyJoules: 3140.0, powderSensitivityMPSPerC: 0.35, category: .hunting, bulletType: "ELD-X Polymer Tip"),
        CatalogAmmunition(manufacturer: "Federal", name: "Gold Medal Match 140gr Sierra MK", caliber: "6.5 Creedmoor", projectileWeightGrains: 140.0, ballisticCoefficient: 0.607, dragFunction: 1, muzzleVelocityMPS: 830.0, muzzleEnergyJoules: 3110.0, powderSensitivityMPSPerC: 0.30, category: .match, bulletType: "Sierra MatchKing HPBT"),
        CatalogAmmunition(manufacturer: "Federal", name: "Gold Medal 140gr Berger Hybrid", caliber: "6.5 Creedmoor", projectileWeightGrains: 140.0, ballisticCoefficient: 0.615, dragFunction: 1, muzzleVelocityMPS: 830.0, muzzleEnergyJoules: 3110.0, powderSensitivityMPSPerC: 0.30, category: .match, bulletType: "Berger Hybrid OTM"),
        CatalogAmmunition(manufacturer: "Lapua", name: "Scenar-L 136gr OTM", caliber: "6.5 Creedmoor", projectileWeightGrains: 136.0, ballisticCoefficient: 0.545, dragFunction: 1, muzzleVelocityMPS: 840.0, muzzleEnergyJoules: 3117.0, powderSensitivityMPSPerC: 0.25, category: .match, bulletType: "Scenar-L OTM (GB546)"),
        CatalogAmmunition(manufacturer: "Norma", name: "Golden Target 143gr", caliber: "6.5 Creedmoor", projectileWeightGrains: 143.0, ballisticCoefficient: 0.620, dragFunction: 1, muzzleVelocityMPS: 830.0, muzzleEnergyJoules: 3194.0, powderSensitivityMPSPerC: 0.28, category: .match, bulletType: "Golden Target Match HPBT"),
        CatalogAmmunition(manufacturer: "Sellier & Bellot", name: "FMJ 140gr", caliber: "6.5 Creedmoor", projectileWeightGrains: 140.0, ballisticCoefficient: 0.460, dragFunction: 1, muzzleVelocityMPS: 810.0, muzzleEnergyJoules: 2975.0, powderSensitivityMPSPerC: 0.40, category: .training, bulletType: "FMJ Boat Tail"),

        // ==========================================
        // .308 Win / 7.62x51 NATO
        // ==========================================
        CatalogAmmunition(manufacturer: "Federal", name: "Gold Medal Match 168gr Sierra MK", caliber: ".308 Win", projectileWeightGrains: 168.0, ballisticCoefficient: 0.462, dragFunction: 1, muzzleVelocityMPS: 808.0, muzzleEnergyJoules: 3525.0, powderSensitivityMPSPerC: 0.35, category: .match, bulletType: "Sierra MatchKing BTHP"),
        CatalogAmmunition(manufacturer: "Federal", name: "Gold Medal Match 175gr Sierra MK", caliber: ".308 Win", projectileWeightGrains: 175.0, ballisticCoefficient: 0.505, dragFunction: 1, muzzleVelocityMPS: 792.0, muzzleEnergyJoules: 3560.0, powderSensitivityMPSPerC: 0.35, category: .match, bulletType: "Sierra MatchKing BTHP"),
        CatalogAmmunition(manufacturer: "Federal", name: "Gold Medal 185gr Berger Juggernaut", caliber: ".308 Win", projectileWeightGrains: 185.0, ballisticCoefficient: 0.552, dragFunction: 1, muzzleVelocityMPS: 770.0, muzzleEnergyJoules: 3560.0, powderSensitivityMPSPerC: 0.30, category: .match, bulletType: "Berger Juggernaut OTM"),
        CatalogAmmunition(manufacturer: "Hornady", name: "ELD Match 168gr", caliber: ".308 Win", projectileWeightGrains: 168.0, ballisticCoefficient: 0.523, dragFunction: 1, muzzleVelocityMPS: 823.0, muzzleEnergyJoules: 3694.0, powderSensitivityMPSPerC: 0.35, category: .match, bulletType: "ELD-Match Polymer Tip"),
        CatalogAmmunition(manufacturer: "Hornady", name: "ELD Match 178gr", caliber: ".308 Win", projectileWeightGrains: 178.0, ballisticCoefficient: 0.547, dragFunction: 1, muzzleVelocityMPS: 792.0, muzzleEnergyJoules: 3624.0, powderSensitivityMPSPerC: 0.35, category: .match, bulletType: "ELD-Match Polymer Tip"),
        CatalogAmmunition(manufacturer: "Lapua", name: "Scenar 155gr OTM", caliber: ".308 Win", projectileWeightGrains: 155.0, ballisticCoefficient: 0.460, dragFunction: 1, muzzleVelocityMPS: 860.0, muzzleEnergyJoules: 3720.0, powderSensitivityMPSPerC: 0.25, category: .match, bulletType: "Scenar OTM (GB491)"),
        CatalogAmmunition(manufacturer: "Lapua", name: "Scenar 167gr OTM", caliber: ".308 Win", projectileWeightGrains: 167.0, ballisticCoefficient: 0.446, dragFunction: 1, muzzleVelocityMPS: 820.0, muzzleEnergyJoules: 3640.0, powderSensitivityMPSPerC: 0.25, category: .match, bulletType: "Scenar OTM (GB422)"),
        CatalogAmmunition(manufacturer: "Lapua", name: "Scenar 175gr OTM", caliber: ".308 Win", projectileWeightGrains: 175.0, ballisticCoefficient: 0.490, dragFunction: 1, muzzleVelocityMPS: 800.0, muzzleEnergyJoules: 3632.0, powderSensitivityMPSPerC: 0.25, category: .match, bulletType: "Scenar-L OTM (GB550)"),
        CatalogAmmunition(manufacturer: "Lapua", name: "Scenar 185gr OTM", caliber: ".308 Win", projectileWeightGrains: 185.0, ballisticCoefficient: 0.482, dragFunction: 1, muzzleVelocityMPS: 755.0, muzzleEnergyJoules: 3418.0, powderSensitivityMPSPerC: 0.25, category: .match, bulletType: "Scenar OTM (GB432)"),
        CatalogAmmunition(manufacturer: "GGG", name: "GGG .308 Win 147gr FMJ", caliber: ".308 Win", projectileWeightGrains: 147.0, ballisticCoefficient: 0.400, dragFunction: 1, muzzleVelocityMPS: 842.0, muzzleEnergyJoules: 3374.0, powderSensitivityMPSPerC: 0.35, category: .training, bulletType: "FMJ NATO"),
        CatalogAmmunition(manufacturer: "GGG", name: "GGG .308 Win 168gr Sierra MK", caliber: ".308 Win", projectileWeightGrains: 168.0, ballisticCoefficient: 0.462, dragFunction: 1, muzzleVelocityMPS: 805.0, muzzleEnergyJoules: 3500.0, powderSensitivityMPSPerC: 0.30, category: .match, bulletType: "Sierra MatchKing HPBT"),
        CatalogAmmunition(manufacturer: "GGG", name: "GGG .308 Win 175gr Sierra MK", caliber: ".308 Win", projectileWeightGrains: 175.0, ballisticCoefficient: 0.505, dragFunction: 1, muzzleVelocityMPS: 790.0, muzzleEnergyJoules: 3540.0, powderSensitivityMPSPerC: 0.30, category: .match, bulletType: "Sierra MatchKing HPBT"),
        CatalogAmmunition(manufacturer: "Norma", name: "Diamond Line 168gr Sierra", caliber: ".308 Win", projectileWeightGrains: 168.0, ballisticCoefficient: 0.462, dragFunction: 1, muzzleVelocityMPS: 805.0, muzzleEnergyJoules: 3500.0, powderSensitivityMPSPerC: 0.28, category: .match, bulletType: "Moly Coated Sierra MK"),
        CatalogAmmunition(manufacturer: "RWS", name: "Target Elite Plus 168gr", caliber: ".308 Win", projectileWeightGrains: 168.0, ballisticCoefficient: 0.462, dragFunction: 1, muzzleVelocityMPS: 805.0, muzzleEnergyJoules: 3500.0, powderSensitivityMPSPerC: 0.28, category: .match, bulletType: "MatchKing HPBT"),
        CatalogAmmunition(manufacturer: "Remington", name: "Core-Lokt 150gr PSP", caliber: ".308 Win", projectileWeightGrains: 150.0, ballisticCoefficient: 0.314, dragFunction: 1, muzzleVelocityMPS: 859.0, muzzleEnergyJoules: 3591.0, powderSensitivityMPSPerC: 0.40, category: .hunting, bulletType: "Pointed Soft Point"),
        CatalogAmmunition(manufacturer: "Winchester", name: "Super-X 150gr Power-Point", caliber: ".308 Win", projectileWeightGrains: 150.0, ballisticCoefficient: 0.294, dragFunction: 1, muzzleVelocityMPS: 860.0, muzzleEnergyJoules: 3600.0, powderSensitivityMPSPerC: 0.40, category: .hunting, bulletType: "Power-Point Soft Nose"),

        // ==========================================
        // .30-06 Springfield
        // ==========================================
        CatalogAmmunition(manufacturer: "Federal", name: "Fusion 165gr Bonded", caliber: ".30-06", projectileWeightGrains: 165.0, ballisticCoefficient: 0.440, dragFunction: 1, muzzleVelocityMPS: 853.0, muzzleEnergyJoules: 3894.0, powderSensitivityMPSPerC: 0.35, category: .hunting, bulletType: "Fusion Bonded SP"),
        CatalogAmmunition(manufacturer: "Hornady", name: "Superformance 165gr SST", caliber: ".30-06", projectileWeightGrains: 165.0, ballisticCoefficient: 0.447, dragFunction: 1, muzzleVelocityMPS: 899.0, muzzleEnergyJoules: 4323.0, powderSensitivityMPSPerC: 0.35, category: .hunting, bulletType: "SST Polymer Tip"),
        CatalogAmmunition(manufacturer: "Norma", name: "Oryx 180gr Bonded", caliber: ".30-06", projectileWeightGrains: 180.0, ballisticCoefficient: 0.385, dragFunction: 1, muzzleVelocityMPS: 823.0, muzzleEnergyJoules: 3949.0, powderSensitivityMPSPerC: 0.32, category: .hunting, bulletType: "Oryx Bonded Soft Point"),

        // ==========================================
        // .300 Win Mag
        // ==========================================
        CatalogAmmunition(manufacturer: "Federal", name: "Gold Medal Match 190gr Sierra MK", caliber: ".300 Win Mag", projectileWeightGrains: 190.0, ballisticCoefficient: 0.533, dragFunction: 1, muzzleVelocityMPS: 884.0, muzzleEnergyJoules: 4807.0, powderSensitivityMPSPerC: 0.35, category: .match, bulletType: "Sierra MatchKing BTHP"),
        CatalogAmmunition(manufacturer: "Federal", name: "Gold Medal 215gr Berger Hybrid", caliber: ".300 Win Mag", projectileWeightGrains: 215.0, ballisticCoefficient: 0.691, dragFunction: 1, muzzleVelocityMPS: 870.0, muzzleEnergyJoules: 5275.0, powderSensitivityMPSPerC: 0.30, category: .match, bulletType: "Berger Hybrid OTM"),
        CatalogAmmunition(manufacturer: "Hornady", name: "Precision Hunter 200gr ELD-X", caliber: ".300 Win Mag", projectileWeightGrains: 200.0, ballisticCoefficient: 0.626, dragFunction: 1, muzzleVelocityMPS: 869.0, muzzleEnergyJoules: 4880.0, powderSensitivityMPSPerC: 0.35, category: .hunting, bulletType: "ELD-X Polymer Tip"),
        CatalogAmmunition(manufacturer: "Lapua", name: "Scenar 185gr OTM", caliber: ".300 Win Mag", projectileWeightGrains: 185.0, ballisticCoefficient: 0.482, dragFunction: 1, muzzleVelocityMPS: 930.0, muzzleEnergyJoules: 5190.0, powderSensitivityMPSPerC: 0.25, category: .match, bulletType: "Scenar OTM (GB432)"),

        // ==========================================
        // .338 Lapua Mag (ELR / Sniper)
        // ==========================================
        CatalogAmmunition(manufacturer: "Lapua", name: "Scenar 250gr OTM (GB488)", caliber: ".338 Lapua Mag", projectileWeightGrains: 250.0, ballisticCoefficient: 0.648, dragFunction: 1, muzzleVelocityMPS: 900.0, muzzleEnergyJoules: 6561.0, powderSensitivityMPSPerC: 0.25, category: .match, bulletType: "Scenar OTM Match (GB488)"),
        CatalogAmmunition(manufacturer: "Lapua", name: "Scenar 300gr OTM (GB528)", caliber: ".338 Lapua Mag", projectileWeightGrains: 300.0, ballisticCoefficient: 0.785, dragFunction: 1, muzzleVelocityMPS: 830.0, muzzleEnergyJoules: 6702.0, powderSensitivityMPSPerC: 0.25, category: .match, bulletType: "Scenar OTM ELR (GB528)"),
        CatalogAmmunition(manufacturer: "Hornady", name: "ELD Match 285gr ELD-M", caliber: ".338 Lapua Mag", projectileWeightGrains: 285.0, ballisticCoefficient: 0.789, dragFunction: 1, muzzleVelocityMPS: 837.0, muzzleEnergyJoules: 6450.0, powderSensitivityMPSPerC: 0.30, category: .match, bulletType: "ELD-Match Polymer Tip"),
        CatalogAmmunition(manufacturer: "Federal", name: "Gold Medal 250gr Sierra MatchKing", caliber: ".338 Lapua Mag", projectileWeightGrains: 250.0, ballisticCoefficient: 0.675, dragFunction: 1, muzzleVelocityMPS: 895.0, muzzleEnergyJoules: 6488.0, powderSensitivityMPSPerC: 0.30, category: .match, bulletType: "Sierra MatchKing BTHP"),
        CatalogAmmunition(manufacturer: "Swiss P", name: "Target 250gr", caliber: ".338 Lapua Mag", projectileWeightGrains: 250.0, ballisticCoefficient: 0.675, dragFunction: 1, muzzleVelocityMPS: 890.0, muzzleEnergyJoules: 6416.0, powderSensitivityMPSPerC: 0.20, category: .match, bulletType: "Swiss P Military HPBT"),

        // ==========================================
        // 9mm Luger (Arme de Poing / PCC)
        // ==========================================
        CatalogAmmunition(manufacturer: "Winchester", name: "White Box 115gr FMJ", caliber: "9mm Luger", projectileWeightGrains: 115.0, ballisticCoefficient: 0.155, dragFunction: 1, muzzleVelocityMPS: 362.0, muzzleEnergyJoules: 487.0, powderSensitivityMPSPerC: 0.20, category: .training, bulletType: "FMJ Round Nose"),
        CatalogAmmunition(manufacturer: "Federal", name: "HST 124gr JHP", caliber: "9mm Luger", projectileWeightGrains: 124.0, ballisticCoefficient: 0.170, dragFunction: 1, muzzleVelocityMPS: 350.0, muzzleEnergyJoules: 490.0, powderSensitivityMPSPerC: 0.20, category: .hunting, bulletType: "HST Tactical JHP"),
        CatalogAmmunition(manufacturer: "Geco", name: "DTX 124gr FMJ", caliber: "9mm Luger", projectileWeightGrains: 124.0, ballisticCoefficient: 0.160, dragFunction: 1, muzzleVelocityMPS: 360.0, muzzleEnergyJoules: 518.0, powderSensitivityMPSPerC: 0.20, category: .training, bulletType: "FMJ Round Nose")
    ]

    // MARK: - Comprehensive Catalog of Reference Weapons / Precision Rifles
    static let catalogWeapons: [CatalogWeapon] = [
        // Tikka
        CatalogWeapon(manufacturer: "Tikka", name: "T3x TAC A1", caliber: ".308 Win", twistRateInches: 11.0, twistDirection: .right, sightHeightCM: 4.5, defaultScopeUnit: .mrad10, category: "Châssis Précision TLD"),
        CatalogWeapon(manufacturer: "Tikka", name: "T3x TAC A1", caliber: "6.5 Creedmoor", twistRateInches: 8.0, twistDirection: .right, sightHeightCM: 4.5, defaultScopeUnit: .mrad10, category: "Châssis Précision TLD"),
        CatalogWeapon(manufacturer: "Tikka", name: "T3x CTR", caliber: ".308 Win", twistRateInches: 11.0, twistDirection: .right, sightHeightCM: 3.8, defaultScopeUnit: .mrad10, category: "Compact Tactical Rifle"),
        CatalogWeapon(manufacturer: "Tikka", name: "T3x CTR", caliber: "6.5 Creedmoor", twistRateInches: 8.0, twistDirection: .right, sightHeightCM: 3.8, defaultScopeUnit: .mrad10, category: "Compact Tactical Rifle"),
        CatalogWeapon(manufacturer: "Tikka", name: "T3x Super Varmint", caliber: ".223 Rem", twistRateInches: 8.0, twistDirection: .right, sightHeightCM: 3.8, defaultScopeUnit: .moa18, category: "Varmint / Précision"),
        CatalogWeapon(manufacturer: "Tikka", name: "T1x MTR", caliber: ".22 LR", twistRateInches: 16.5, twistDirection: .right, sightHeightCM: 3.5, defaultScopeUnit: .moa18, category: "Rimfire Précision"),

        // Bergara
        CatalogWeapon(manufacturer: "Bergara", name: "B14 HMR", caliber: ".308 Win", twistRateInches: 10.0, twistDirection: .right, sightHeightCM: 4.0, defaultScopeUnit: .mrad10, category: "Hunting & Match Rifle"),
        CatalogWeapon(manufacturer: "Bergara", name: "B14 HMR", caliber: "6.5 Creedmoor", twistRateInches: 8.0, twistDirection: .right, sightHeightCM: 4.0, defaultScopeUnit: .mrad10, category: "Hunting & Match Rifle"),
        CatalogWeapon(manufacturer: "Bergara", name: "B14 BMP", caliber: "6.5 Creedmoor", twistRateInches: 8.0, twistDirection: .right, sightHeightCM: 4.5, defaultScopeUnit: .mrad10, category: "Châssis Match Précision"),
        CatalogWeapon(manufacturer: "Bergara", name: "B14 BMP", caliber: ".308 Win", twistRateInches: 10.0, twistDirection: .right, sightHeightCM: 4.5, defaultScopeUnit: .mrad10, category: "Châssis Match Précision"),
        CatalogWeapon(manufacturer: "Bergara", name: "B14 Wilderness Ridge", caliber: ".300 Win Mag", twistRateInches: 10.0, twistDirection: .right, sightHeightCM: 3.8, defaultScopeUnit: .moa14, category: "Longue Portée Chasse"),

        // Savage
        CatalogWeapon(manufacturer: "Savage", name: "B22 Precision", caliber: ".22 LR", twistRateInches: 16.0, twistDirection: .right, sightHeightCM: 4.0, defaultScopeUnit: .moa18, category: "Châssis MDT Rimfire"),
        CatalogWeapon(manufacturer: "Savage", name: "Axis II Precision", caliber: ".308 Win", twistRateInches: 10.0, twistDirection: .right, sightHeightCM: 4.0, defaultScopeUnit: .moa18, category: "Châssis MDT TLD"),
        CatalogWeapon(manufacturer: "Savage", name: "Axis II Precision", caliber: "6.5 Creedmoor", twistRateInches: 8.0, twistDirection: .right, sightHeightCM: 4.0, defaultScopeUnit: .moa18, category: "Châssis MDT TLD"),
        CatalogWeapon(manufacturer: "Savage", name: "110 Elite Precision", caliber: ".308 Win", twistRateInches: 10.0, twistDirection: .right, sightHeightCM: 4.5, defaultScopeUnit: .mrad10, category: "Compétition PRS / ELR"),
        CatalogWeapon(manufacturer: "Savage", name: "110 Elite Precision", caliber: "6.5 Creedmoor", twistRateInches: 8.0, twistDirection: .right, sightHeightCM: 4.5, defaultScopeUnit: .mrad10, category: "Compétition PRS / ELR"),
        CatalogWeapon(manufacturer: "Savage", name: "110 Elite Precision", caliber: ".338 Lapua Mag", twistRateInches: 9.0, twistDirection: .right, sightHeightCM: 4.5, defaultScopeUnit: .mrad10, category: "ELR Extreme Long Range"),

        // CZ
        CatalogWeapon(manufacturer: "CZ", name: "457 LRP", caliber: ".22 LR", twistRateInches: 16.0, twistDirection: .right, sightHeightCM: 4.0, defaultScopeUnit: .moa18, category: "Long Range Precision .22"),
        CatalogWeapon(manufacturer: "CZ", name: "457 Varmint MTR", caliber: ".22 LR", twistRateInches: 16.0, twistDirection: .right, sightHeightCM: 3.8, defaultScopeUnit: .moa18, category: "Match Target Rifle"),
        CatalogWeapon(manufacturer: "CZ", name: "600 Range", caliber: ".308 Win", twistRateInches: 10.0, twistDirection: .right, sightHeightCM: 4.2, defaultScopeUnit: .mrad10, category: "Crosse Bois Lamellé TLD"),
        CatalogWeapon(manufacturer: "CZ", name: "600 Range", caliber: "6.5 Creedmoor", twistRateInches: 8.0, twistDirection: .right, sightHeightCM: 4.2, defaultScopeUnit: .mrad10, category: "Crosse Bois Lamellé TLD"),

        // Ruger
        CatalogWeapon(manufacturer: "Ruger", name: "Precision Rifle (RPR)", caliber: ".308 Win", twistRateInches: 10.0, twistDirection: .right, sightHeightCM: 4.5, defaultScopeUnit: .mrad10, category: "Châssis Hybride TLD"),
        CatalogWeapon(manufacturer: "Ruger", name: "Precision Rifle (RPR)", caliber: "6.5 Creedmoor", twistRateInches: 8.0, twistDirection: .right, sightHeightCM: 4.5, defaultScopeUnit: .mrad10, category: "Châssis Hybride TLD"),
        CatalogWeapon(manufacturer: "Ruger", name: "Precision Rifle (RPR)", caliber: ".338 Lapua Mag", twistRateInches: 9.37, twistDirection: .right, sightHeightCM: 4.5, defaultScopeUnit: .mrad10, category: "Magnum ELR"),
        CatalogWeapon(manufacturer: "Ruger", name: "Precision Rimfire", caliber: ".22 LR", twistRateInches: 16.0, twistDirection: .right, sightHeightCM: 4.0, defaultScopeUnit: .moa18, category: "Châssis .22 LR"),

        // Sako
        CatalogWeapon(manufacturer: "Sako", name: "TRG 22", caliber: ".308 Win", twistRateInches: 11.0, twistDirection: .right, sightHeightCM: 4.5, defaultScopeUnit: .mrad10, category: "Sniper Militaire / Match"),
        CatalogWeapon(manufacturer: "Sako", name: "TRG 42", caliber: ".338 Lapua Mag", twistRateInches: 10.0, twistDirection: .right, sightHeightCM: 4.5, defaultScopeUnit: .mrad10, category: "Sniper Longue Portée"),
        CatalogWeapon(manufacturer: "Sako", name: "S20 Precision", caliber: "6.5 Creedmoor", twistRateInches: 8.0, twistDirection: .right, sightHeightCM: 4.2, defaultScopeUnit: .mrad10, category: "Châssis Modulaire"),

        // Accuracy International
        CatalogWeapon(manufacturer: "Accuracy International", name: "AXMC", caliber: ".308 Win", twistRateInches: 10.0, twistDirection: .right, sightHeightCM: 4.5, defaultScopeUnit: .mrad10, category: "Multi-Calibre Militaire"),
        CatalogWeapon(manufacturer: "Accuracy International", name: "AXMC", caliber: ".338 Lapua Mag", twistRateInches: 9.35, twistDirection: .right, sightHeightCM: 4.5, defaultScopeUnit: .mrad10, category: "Multi-Calibre Militaire"),
        CatalogWeapon(manufacturer: "Accuracy International", name: "AT-X", caliber: "6.5 Creedmoor", twistRateInches: 8.0, twistDirection: .right, sightHeightCM: 4.5, defaultScopeUnit: .mrad10, category: "Compétition PRS Pro"),

        // Remington
        CatalogWeapon(manufacturer: "Remington", name: "700 SPS Tactical", caliber: ".308 Win", twistRateInches: 10.0, twistDirection: .right, sightHeightCM: 3.8, defaultScopeUnit: .moa14, category: "Tactical Bolt Action"),
        CatalogWeapon(manufacturer: "Remington", name: "700 Police", caliber: ".300 Win Mag", twistRateInches: 10.0, twistDirection: .right, sightHeightCM: 3.8, defaultScopeUnit: .moa14, category: "Law Enforcement Sniper")
    ]
}

