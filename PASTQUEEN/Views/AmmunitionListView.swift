//
//  AmmunitionListView.swift
//  PASTQUEEN
//

import SwiftUI
import SwiftData

struct AmmunitionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var ammunitions: [BallisticSettings]
    @Binding var selectedAmmunition: BallisticSettings?

    var body: some View {
        List {
            ForEach(ammunitions) { ammo in
                Button {
                    selectedAmmunition = ammo
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "target")
                            .foregroundStyle(.green)
                        VStack(alignment: .leading) {
                            Text(ammo.ammunitionName)
                                .font(.headline)
                                .fontDesign(.rounded)
                                .fontWeight(.light)
                                .foregroundStyle(.primary)
                            Text("\(ammo.calibre) - \(ammo.projectileWeightGrains, format: .number)gr")
                                .font(.subheadline)
                                .fontDesign(.rounded)
                                .fontWeight(.light)
                                .foregroundStyle(.secondary)
                        }
                        if selectedAmmunition == ammo || (selectedAmmunition == nil && ammo == ammunitions.first) {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .onDelete(perform: deleteAmmunition)
        }
        .navigationTitle(String(localized: .ammunitions))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(value: "AddAmmunition") {
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
            if value == "AddAmmunition" {
                AddView()
            }
        }
    }

    private func deleteAmmunition(offsets: IndexSet) {
        let deletedSelected = offsets.contains { ammunitions[$0] == selectedAmmunition }
        for index in offsets {
            modelContext.delete(ammunitions[index])
        }
        if deletedSelected {
            selectedAmmunition = nil
        }
    }
}
