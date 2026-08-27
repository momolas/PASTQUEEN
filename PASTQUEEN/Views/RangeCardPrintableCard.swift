//
//  RangeCardPrintableCard.swift
//  PASTQUEEN
//

import SwiftUI

struct RangeCardPrintableCard: View {
    let weaponName: String
    let caliber: String
    let scopeUnit: String
    let zeroDistance: Double
    let ammoName: String
    let bulletWeight: Double
    let muzzleVelocity: Double
    let weatherSummary: String
    let rows: [RangeCardRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(weaponName)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.primary)
                    Text("\(caliber) • Zéro: \(Int(zeroDistance))m • Tourelle: \(scopeUnit)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(ammoName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("\(Int(bulletWeight)) gr • \(Int(muzzleVelocity)) m/s")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 4)

            if !weatherSummary.isEmpty {
                Text("Conditions : \(weatherSummary)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Table Header
            HStack {
                Text("Distance")
                    .frame(width: 70, alignment: .leading)
                Spacer()
                Text("Élévation")
                    .frame(width: 100, alignment: .center)
                Spacer()
                Text("Dérive (Vent)")
                    .frame(width: 100, alignment: .center)
                Spacer()
                Text("Vitesse")
                    .frame(width: 70, alignment: .trailing)
            }
            .font(.caption)
            .bold()
            .foregroundStyle(.secondary)
            .padding(.vertical, 4)

            Divider()

            // Rows
            ForEach(rows) { row in
                HStack {
                    Text("\(row.distance) m")
                        .font(.subheadline)
                        .bold()
                        .frame(width: 70, alignment: .leading)
                    Spacer()
                    VStack(alignment: .center, spacing: 1) {
                        Text("\(row.dropClicks) clics")
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(.blue)
                        Text("\(row.dropMOA, format: .number.precision(.fractionLength(1))) MOA")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 100, alignment: .center)
                    Spacer()
                    VStack(alignment: .center, spacing: 1) {
                        Text("\(row.windageClicks) clics")
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(.orange)
                        Text("\(row.windageMOA, format: .number.precision(.fractionLength(1))) MOA")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 100, alignment: .center)
                    Spacer()
                    Text("\(Int(row.velocity)) m/s")
                        .font(.subheadline)
                        .frame(width: 70, alignment: .trailing)
                }
                .padding(.vertical, 2)
            }
        }
        .padding(20)
        .background(Color(uiColor: .systemBackground))
        .frame(width: 440)
    }
}
