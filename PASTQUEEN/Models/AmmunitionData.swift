//
//  AmmunitionData.swift
//  PASTQUEEN
//
//  Created by Jules on 26/10/2025.
//

import Foundation

struct AmmunitionData: Codable {
    let calibers: [String]
    let dragFunctions: [DragFunction]
}

struct DragFunction: Codable, Identifiable {
    let id: Int
    let name: String
}
