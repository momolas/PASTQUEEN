//
//  WeaponListView.swift
//  PASTQUEEN
//
//  Created by Mo on 27/08/2026.
//

import SwiftUI
import SwiftData

struct WeaponListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Weapon.name) private var weapons: [Weapon]
    @Binding var selectedWeapon: Weapon?

    var body: some View {
        List {
            ForEach(weapons) { weapon in
                Button {
                    selectedWeapon = weapon
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "scope")
                            .font(.title3)
                            .foregroundStyle(.blue)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(weapon.name)
                                .font(.headline)
                                .fontDesign(.rounded)
                                .foregroundStyle(.primary)

                            HStack(spacing: 6) {
                                Text(weapon.calibre)
                                    .font(.caption2)
                                    .bold()
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.15), in: Capsule())
                                    .foregroundStyle(.blue)

                                Text("Zéro : \(Int(weapon.zeroRangeMeters))m")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        if selectedWeapon == weapon || (selectedWeapon == nil && weapon == weapons.first) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .onDelete(perform: deleteWeapon)
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Mes Armes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(value: "AddWeapon") {
                    Label("Ajouter", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Fermer") {
                    dismiss()
                }
            }
        }
        .navigationDestination(for: String.self) { value in
            if value == "AddWeapon" {
                AddWeaponView()
            }
        }
    }

    private func deleteWeapon(offsets: IndexSet) {
        let deletedSelected = offsets.contains { weapons[$0] == selectedWeapon }
        for index in offsets {
            modelContext.delete(weapons[index])
        }
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context after deleting weapon: \(error)")
        }
        if deletedSelected {
            selectedWeapon = nil
        }
    }
}
