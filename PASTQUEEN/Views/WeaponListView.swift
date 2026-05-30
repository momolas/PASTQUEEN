//
//  WeaponListView.swift
//  PASTQUEEN
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
                    HStack {
                        Image(systemName: "scope")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading) {
                            Text(weapon.name)
                                .font(.headline)
                                .fontDesign(.rounded)
                                .foregroundStyle(.primary)
                            Text("\(weapon.calibre) • \(Text(.zeroRangeLabel)): \(weapon.zeroRangeMeters, format: .number)m")
                                .font(.subheadline)
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                        }
                        if selectedWeapon == weapon || (selectedWeapon == nil && weapon == weapons.first) {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .onDelete(perform: deleteWeapon)
        }
        .navigationTitle(String(localized: .ammunitions)) // Localized header
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(value: "AddWeapon") {
                    Label("Add", systemImage: "plus")
                }
                .labelStyle(.iconOnly)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
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
