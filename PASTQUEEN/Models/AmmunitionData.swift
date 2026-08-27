//
//  AmmunitionData.swift
//  PASTQUEEN
//
//  Created by Jules on 26/10/2025.
//

import Foundation

struct MarketAmmunition: Identifiable, Hashable {
    var id: String { "\(manufacturer) \(name)" }
    let manufacturer: String
    let name: String
    let caliber: String
    let projectileWeightGrains: Double
    let ballisticCoefficient: Double
    let dragFunction: Int32
    let muzzleVelocityMPS: Double
    let muzzleEnergyJoules: Double
}

struct AmmunitionData {
    static let calibers: [String] = [
        ".22 LR",
        ".223 Rem",
        ".308 Win",
        "6.5 Creedmoor",
        "9mm Luger",
        ".300 Win Mag",
        ".338 Lapua Mag"
    ]
    
    static let dragFunctions: [DragFunctionItem] = [
        DragFunctionItem(id: 1, name: "G1"),
        DragFunctionItem(id: 2, name: "G2"),
        DragFunctionItem(id: 5, name: "G5"),
        DragFunctionItem(id: 6, name: "G6"),
        DragFunctionItem(id: 7, name: "G7"),
        DragFunctionItem(id: 8, name: "G8")
    ]
    
    static let commonLoads: [MarketAmmunition] = [
        // .22 LR
        MarketAmmunition(manufacturer: "Solognac (Decathlon)", name: "22 LR Standard Training 40gr", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.125, dragFunction: 1, muzzleVelocityMPS: 325.0, muzzleEnergyJoules: 137.0),
        MarketAmmunition(manufacturer: "Solognac (Decathlon)", name: "22 LR High Velocity 36gr", caliber: ".22 LR", projectileWeightGrains: 36.0, ballisticCoefficient: 0.118, dragFunction: 1, muzzleVelocityMPS: 385.0, muzzleEnergyJoules: 173.0),
        MarketAmmunition(manufacturer: "Solognac (Decathlon)", name: "22 LR Subsonic Hollow Point 40gr", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.115, dragFunction: 1, muzzleVelocityMPS: 315.0, muzzleEnergyJoules: 128.0),

        MarketAmmunition(manufacturer: "CCI", name: "Standard Velocity", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.120, dragFunction: 1, muzzleVelocityMPS: 326.0, muzzleEnergyJoules: 137.0),
        MarketAmmunition(manufacturer: "ELEY", name: "Match", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.150, dragFunction: 1, muzzleVelocityMPS: 329.0, muzzleEnergyJoules: 140.0),
        MarketAmmunition(manufacturer: "RWS", name: "Target Rifle", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.110, dragFunction: 1, muzzleVelocityMPS: 330.0, muzzleEnergyJoules: 142.0),
        MarketAmmunition(manufacturer: "Federal", name: "Champion", caliber: ".22 LR", projectileWeightGrains: 40.0, ballisticCoefficient: 0.125, dragFunction: 1, muzzleVelocityMPS: 378.0, muzzleEnergyJoules: 185.0),
        
        // .308 Win / 7.62x51 NATO
        MarketAmmunition(manufacturer: "GGG", name: "GGG .308 Win 147gr FMJ", caliber: ".308 Win", projectileWeightGrains: 147.0, ballisticCoefficient: 0.400, dragFunction: 1, muzzleVelocityMPS: 842.0, muzzleEnergyJoules: 3374.0),
        MarketAmmunition(manufacturer: "Federal", name: "Gold Medal Match 168gr", caliber: ".308 Win", projectileWeightGrains: 168.0, ballisticCoefficient: 0.462, dragFunction: 1, muzzleVelocityMPS: 808.0, muzzleEnergyJoules: 3525.0),
        MarketAmmunition(manufacturer: "Hornady", name: "ELD Match 178gr", caliber: ".308 Win", projectileWeightGrains: 178.0, ballisticCoefficient: 0.547, dragFunction: 1, muzzleVelocityMPS: 792.0, muzzleEnergyJoules: 3624.0),
        MarketAmmunition(manufacturer: "Remington", name: "Core-Lokt 150gr PSP", caliber: ".308 Win", projectileWeightGrains: 150.0, ballisticCoefficient: 0.314, dragFunction: 1, muzzleVelocityMPS: 859.0, muzzleEnergyJoules: 3591.0),

        
        // .223 Rem
        MarketAmmunition(manufacturer: "Federal", name: "Gold Medal Match 69gr", caliber: ".223 Rem", projectileWeightGrains: 69.0, ballisticCoefficient: 0.301, dragFunction: 1, muzzleVelocityMPS: 899.0, muzzleEnergyJoules: 1809.0),
        MarketAmmunition(manufacturer: "Hornady", name: "Frontier 55gr FMJ", caliber: ".223 Rem", projectileWeightGrains: 55.0, ballisticCoefficient: 0.243, dragFunction: 1, muzzleVelocityMPS: 987.0, muzzleEnergyJoules: 1735.0),
        
        // 6.5 Creedmoor
        MarketAmmunition(manufacturer: "Hornady", name: "ELD Match 140gr", caliber: "6.5 Creedmoor", projectileWeightGrains: 140.0, ballisticCoefficient: 0.646, dragFunction: 1, muzzleVelocityMPS: 826.0, muzzleEnergyJoules: 3087.0),
        MarketAmmunition(manufacturer: "Federal", name: "Gold Medal Match 140gr", caliber: "6.5 Creedmoor", projectileWeightGrains: 140.0, ballisticCoefficient: 0.607, dragFunction: 1, muzzleVelocityMPS: 830.0, muzzleEnergyJoules: 3110.0),
        
        // 9mm Luger
        MarketAmmunition(manufacturer: "Winchester", name: "White Box 115gr FMJ", caliber: "9mm Luger", projectileWeightGrains: 115.0, ballisticCoefficient: 0.155, dragFunction: 1, muzzleVelocityMPS: 362.0, muzzleEnergyJoules: 487.0),
        MarketAmmunition(manufacturer: "Federal", name: "HST 124gr JHP", caliber: "9mm Luger", projectileWeightGrains: 124.0, ballisticCoefficient: 0.170, dragFunction: 1, muzzleVelocityMPS: 350.0, muzzleEnergyJoules: 490.0),
        
        // .300 Win Mag
        MarketAmmunition(manufacturer: "Federal", name: "Gold Medal Match 190gr", caliber: ".300 Win Mag", projectileWeightGrains: 190.0, ballisticCoefficient: 0.533, dragFunction: 1, muzzleVelocityMPS: 884.0, muzzleEnergyJoules: 4807.0),
        MarketAmmunition(manufacturer: "Hornady", name: "Precision Hunter 200gr", caliber: ".300 Win Mag", projectileWeightGrains: 200.0, ballisticCoefficient: 0.626, dragFunction: 1, muzzleVelocityMPS: 869.0, muzzleEnergyJoules: 4880.0),
        
        // .338 Lapua Mag
        MarketAmmunition(manufacturer: "Lapua", name: "Scenar 250gr OTM", caliber: ".338 Lapua Mag", projectileWeightGrains: 250.0, ballisticCoefficient: 0.648, dragFunction: 1, muzzleVelocityMPS: 900.0, muzzleEnergyJoules: 6561.0),
        MarketAmmunition(manufacturer: "Hornady", name: "ELD Match 285gr ELD-M", caliber: ".338 Lapua Mag", projectileWeightGrains: 285.0, ballisticCoefficient: 0.789, dragFunction: 1, muzzleVelocityMPS: 837.0, muzzleEnergyJoules: 6450.0)
    ]
}
