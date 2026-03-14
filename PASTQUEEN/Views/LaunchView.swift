//
//  LaunchView.swift
//  PASTQUEEN
//
//  Created by Mo on 16/09/2022.
//

import SwiftUI
import SwiftData

struct LaunchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var ammunitions: [BallisticSettings]

    var body: some View {
        NavigationStack {
            List {
                ForEach(ammunitions) { ammo in
                    NavigationLink(value: ammo) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundStyle(.green)
                            VStack(alignment: .leading) {
                                Text(ammo.ammunitionName)
                                    .font(.headline)
                                Text("\(ammo.calibre) - \(ammo.projectileWeightGrains, format: .number)gr")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteAmmunition)
            }
            .overlay {
                if ammunitions.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "scope")
                            .font(.system(size: 60))
                            .foregroundStyle(.tertiary)
                            .padding(.bottom, 8)
                        Text(.noAmmunitionProfiles)
                            .font(.headline)
                        Text(.tapToAdd)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(String(localized: .ammunitions))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(value: "AddAmmunition") {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: BallisticSettings.self) { ammo in
                CalculatorView(ballisticSettings: ammo)
            }
            .navigationDestination(for: String.self) { value in
                if value == "AddAmmunition" {
                    AddView()
                }
            }
        }
    }

    private func deleteAmmunition(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(ammunitions[index])
        }
    }
}

#Preview {
	LaunchView()
		.preferredColorScheme(.dark)
		.modelContainer(for: BallisticSettings.self, inMemory: true)
}
