//
//  AmmunitionData.swift
//  PASTQUEEN
//
//  Created by Jules on 26/10/2025.
//

import Foundation

struct AmmunitionData {
    static let calibers: [String] = [".308", ".22LR", ".223", "6.5CM", "9mm", ".300 Win Mag", ".338 Lapua"]
    
    static let dragFunctions: [DragFunction] = [
        DragFunction(id: 1, name: "G1"),
        DragFunction(id: 2, name: "G2"),
        DragFunction(id: 5, name: "G5"),
        DragFunction(id: 6, name: "G6"),
        DragFunction(id: 7, name: "G7"),
        DragFunction(id: 8, name: "G8")
    ]
}

struct DragFunction: Identifiable {
    let id: Int32
    let name: String
}
