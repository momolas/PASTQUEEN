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

    var body: some View {
        NavigationStack {
            if let ammo = selectedAmmunition ?? ammunitions.first {
                CalculatorView(ballisticSettings: ammo)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                showingProfiles = true
                            } label: {
                                Image(systemName: "list.bullet")
                            }
                        }
                    }
                    .sheet(isPresented: $showingProfiles) {
                        NavigationStack {
                            AmmunitionListView(selectedAmmunition: $selectedAmmunition)
                        }
                    }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "scope")
                        .font(.system(size: 60))
                        .foregroundStyle(.tertiary)
                        .padding(.bottom, 8)
                    Text(.noAmmunitionProfiles)
                        .font(.headline)
                        .fontDesign(.rounded)
                        .fontWeight(.light)
                    Text(.tapToAdd)
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .fontWeight(.light)
                        .foregroundStyle(.secondary)
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
