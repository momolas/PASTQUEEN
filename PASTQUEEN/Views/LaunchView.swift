//
//  LaunchView.swift
//  PASTQUEEN
//
//  Created by Mo on 27/08/2026.
//

import SwiftUI
import SwiftData

struct LaunchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Weapon.name) private var weapons: [Weapon]
    @State private var selectedWeapon: Weapon?

    var body: some View {
        NavigationStack {
            if let weapon = selectedWeapon ?? weapons.first {
                QuickHUDView(weapon: weapon)
            } else {
                ContentUnavailableView {
                    Label("Aucune Carabine", systemImage: "scope")
                } description: {
                    Text("Ajoutez votre première arme pour démarrer les calculs balistiques.")
                } actions: {
                    NavigationLink(value: "AddWeapon") {
                        Text("Ajouter une carabine")
                            .bold()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .navigationTitle("PASTQUEEN")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: String.self) { value in
                    if value == "AddWeapon" {
                        AddWeaponView()
                    }
                }
            }
        }
    }
}

#Preview {
    LaunchView()
        .preferredColorScheme(.dark)
        .modelContainer(for: Weapon.self, inMemory: true)
}
