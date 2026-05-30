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
    @State private var selectedAmmunition: BallisticSettings?
    @State private var showingProfiles = false
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 60

    var body: some View {
        NavigationStack {
            if let ammo = selectedAmmunition ?? ammunitions.first {
                CalculatorView(ballisticSettings: ammo)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Profiles", systemImage: "list.bullet") {
                                showingProfiles = true
                            }
                            .labelStyle(.iconOnly)
                        }
                    }
                    .sheet(isPresented: $showingProfiles) {
                        NavigationStack {
                            AmmunitionListView(selectedAmmunition: $selectedAmmunition)
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
                        NavigationLink(value: "AddAmmunition") {
                            Label("Add", systemImage: "plus")
                        }
                        .labelStyle(.iconOnly)
                    }
                }
                .navigationDestination(for: String.self) { value in
                    if value == "AddAmmunition" {
                        AddView()
                    }
                }
            }
        }
    }
}


#Preview {
	LaunchView()
		.preferredColorScheme(.dark)
		.modelContainer(for: BallisticSettings.self, inMemory: true)
}
