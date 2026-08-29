//
//  AmmunitionCatalogPickerSheet.swift
//  PASTQUEEN
//
//  Created by Mo on 29/08/2026.
//

import SwiftUI

struct AmmunitionCatalogPickerSheet: View {
    let weaponCaliber: String?
    let onSelect: (CatalogAmmunition) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedManufacturer: String? = nil
    @State private var selectedCategory: AmmunitionCategory? = nil
    @State private var filterByWeaponCaliberOnly = true

    private var availableManufacturers: [String] {
        let list = Set(AmmunitionData.catalogAmmunitions.map(\.manufacturer))
        return list.sorted()
    }

    private var filteredAmmunitions: [CatalogAmmunition] {
        AmmunitionData.catalogAmmunitions.filter { ammo in
            // Filter by weapon caliber if active
            if let cal = weaponCaliber, filterByWeaponCaliberOnly {
                let matchesCaliber = ammo.caliber.localizedStandardContains(cal) || cal.localizedStandardContains(ammo.caliber)
                if !matchesCaliber { return false }
            }

            // Filter by selected manufacturer
            if let mfg = selectedManufacturer, ammo.manufacturer != mfg {
                return false
            }

            // Filter by category
            if let cat = selectedCategory, ammo.category != cat {
                return false
            }

            // Filter by search text
            if !searchText.isEmpty {
                let query = searchText.trimmingCharacters(in: .whitespaces)
                let matchesName = ammo.name.localizedStandardContains(query)
                let matchesMfg = ammo.manufacturer.localizedStandardContains(query)
                let matchesCal = ammo.caliber.localizedStandardContains(query)
                let matchesBullet = ammo.bulletType.localizedStandardContains(query)
                if !matchesName && !matchesMfg && !matchesCal && !matchesBullet {
                    return false
                }
            }

            return true
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if let cal = weaponCaliber, !cal.isEmpty {
                    Section {
                        Toggle(isOn: $filterByWeaponCaliberOnly) {
                            Label("Filtrer sur mon calibre (\(cal))", systemImage: "scope")
                        }
                    }
                }

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
                    Text("Fabricants")
                }

                Section {
                    if filteredAmmunitions.isEmpty {
                        ContentUnavailableView(
                            "Aucune munition trouvée",
                            systemImage: "tray",
                            description: Text("Essayez d'ajuster vos filtres de recherche ou de désactiver le filtre de calibre.")
                        )
                    } else {
                        ForEach(filteredAmmunitions) { ammo in
                            Button {
                                onSelect(ammo)
                                dismiss()
                            } label: {
                                AmmunitionCatalogRow(ammo: ammo)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Munitions constructeurs (\(filteredAmmunitions.count))")
                }
            }
            .navigationTitle("Catalogue Munitions")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Rechercher par balle, marque, poids...")
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

private struct AmmunitionCatalogRow: View {
    let ammo: CatalogAmmunition

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(ammo.manufacturer)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.secondary)
                
                Spacer()

                Text(ammo.category.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.15))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(.rect(cornerRadius: 8))
            }

            Text(ammo.name)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(ammo.bulletType)
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()
                .padding(.vertical, 2)

            HStack(spacing: 12) {
                Label("\(ammo.projectileWeightGrains.formatted(.number.precision(.fractionLength(0)))) gr", systemImage: "scalemass.fill")
                Label("BC \(ammo.ballisticCoefficient.formatted(.number.precision(.fractionLength(3)))) (G\(ammo.dragFunction))", systemImage: "chart.line.uptrend.xyaxis")
                Label("\(ammo.muzzleVelocityMPS.formatted(.number.precision(.fractionLength(0)))) m/s", systemImage: "speedometer")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
