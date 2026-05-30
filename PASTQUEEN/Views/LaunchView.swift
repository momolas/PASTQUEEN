//
//  LaunchView.swift
//  PASTQUEEN
//

import SwiftUI
import SwiftData

struct LaunchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Weapon.name) private var weapons: [Weapon]
    @State private var selectedWeapon: Weapon?
    @State private var showingProfiles = false
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 60

    var body: some View {
        NavigationStack {
            if let weapon = selectedWeapon ?? weapons.first {
                CalculatorView(weapon: weapon)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Rifles", systemImage: "list.bullet") {
                                showingProfiles = true
                            }
                            .labelStyle(.iconOnly)
                        }
                    }
                    .sheet(isPresented: $showingProfiles) {
                        NavigationStack {
                            WeaponListView(selectedWeapon: $selectedWeapon)
                        }
                    }
            } else {
                VStack {
                    Image(systemName: "scope")
                        .font(.system(size: iconSize))
                        .foregroundStyle(.tertiary)
                        .padding(.bottom)
                    Text(.noAmmunitionProfiles)
                        .font(.headline)
                        .fontDesign(.rounded)
                    Text(.tapToAdd)
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                }
                .navigationBarTitleDisplayMode(.large)
                .navigationTitle(String(localized: .ammunitions))
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink(value: "AddWeapon") {
                            Label("Add", systemImage: "plus")
                        }
                        .labelStyle(.iconOnly)
                    }
                }
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
