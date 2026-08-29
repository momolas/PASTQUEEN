//
//  WeaponCatalogPickerSheet.swift
//  PASTQUEEN
//
//  Created by Mo on 29/08/2026.
//

import SwiftUI
import Ballistics

struct WeaponCatalogPickerSheet: View {
    let onSelect: (CatalogWeapon) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedManufacturer: String? = nil
    @State private var selectedCaliber: String? = nil

    private var availableManufacturers: [String] {
        let list = Set(AmmunitionData.catalogWeapons.map(\.manufacturer))
        return list.sorted()
    }

    private var availableCalibers: [String] {
        let list = Set(AmmunitionData.catalogWeapons.map(\.caliber))
        return list.sorted()
    }

    private var filteredWeapons: [CatalogWeapon] {
        AmmunitionData.catalogWeapons.filter { weapon in
            // Filter by manufacturer
            if let mfg = selectedManufacturer, weapon.manufacturer != mfg {
                return false
            }

            // Filter by caliber
            if let cal = selectedCaliber, weapon.caliber != cal {
                return false
            }

            // Filter by search text
            if !searchText.isEmpty {
                let query = searchText.trimmingCharacters(in: .whitespaces)
                let matchesName = weapon.name.localizedStandardContains(query)
                let matchesMfg = weapon.manufacturer.localizedStandardContains(query)
                let matchesCal = weapon.caliber.localizedStandardContains(query)
                let matchesCat = weapon.category.localizedStandardContains(query)
                if !matchesName && !matchesMfg && !matchesCal && !matchesCat {
                    return false
                }
            }

            return true
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ScrollView(.horizontal) {
                        HStack(spacing: 8) {
                            Button {
                                selectedManufacturer = nil
                            } label: {
                                Text("Toutes marques")
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedManufacturer == nil ? Color.accentColor : Color.secondary.opacity(0.15))
                                    .foregroundStyle(selectedManufacturer == nil ? .white : .primary)
                                    .clipShape(.rect(cornerRadius: 16))
                            }
                            .buttonStyle(.plain)

                            ForEach(availableManufacturers, id: \.self) { mfg in
                                Button {
                                    selectedManufacturer = (selectedManufacturer == mfg) ? nil : mfg
                                } label: {
                                    Text(mfg)
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedManufacturer == mfg ? Color.accentColor : Color.secondary.opacity(0.15))
                                        .foregroundStyle(selectedManufacturer == mfg ? .white : .primary)
                                        .clipShape(.rect(cornerRadius: 16))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .scrollIndicators(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                } header: {
                    Text("Marques d'armes")
                }

                Section {
                    if filteredWeapons.isEmpty {
                        ContentUnavailableView(
                            "Aucune arme trouvée",
                            systemImage: "scope",
                            description: Text("Essayez d'ajuster vos critères ou votre recherche.")
                        )
                    } else {
                        ForEach(filteredWeapons) { weapon in
                            Button {
                                onSelect(weapon)
                                dismiss()
                            } label: {
                                WeaponCatalogRow(weapon: weapon)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Carabines & Modèles (\(filteredWeapons.count))")
                }
            }
            .navigationTitle("Catalogue Armes")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Rechercher par modèle, marque, calibre...")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct WeaponCatalogRow: View {
    let weapon: CatalogWeapon

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(weapon.manufacturer)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.secondary)

                Spacer()

                Text(weapon.category)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.15))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(.rect(cornerRadius: 8))
            }

            HStack {
                Text(weapon.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Text(weapon.caliber)
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(.tint)
            }

            Divider()
                .padding(.vertical, 2)

            HStack(spacing: 12) {
                Label("Pas 1:\(weapon.twistRateInches.formatted(.number.precision(.fractionLength(1))))\"", systemImage: "arrow.triangle.2.circlepath")
                Label("Visée \(weapon.sightHeightCM.formatted(.number.precision(.fractionLength(1)))) cm", systemImage: "ruler")
                Label(weapon.defaultScopeUnit.rawValue, systemImage: "dial.medium")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
