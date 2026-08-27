//
//  PBRView.swift
//  PASTQUEEN
//

import SwiftUI
import Ballistics

struct PBRView: View {
    let weapon: Weapon
    let ammunition: Ammunition

    @State private var vitalDiameterCM: Double = 10.0

    private let presetVitalSizes: [Double] = [8.0, 10.0, 15.0, 20.0, 25.0]

    private var pbrResult: PBR? {
        let dragFunc: DragFunction
        switch ammunition.dragFunction {
        case 7: dragFunc = .g7
        case 2: dragFunc = .g2
        case 5: dragFunc = .g5
        case 6: dragFunc = .g6
        case 8: dragFunc = .g8
        default: dragFunc = .g1
        }

        let result = PBR.solve(
            dragFunction: dragFunc,
            dragCoefficient: ammunition.ballisticCoefficient,
            initialVelocity: Measurement(value: ammunition.muzzleVelocityMPS, unit: .metersPerSecond),
            sightHeight: Measurement(value: weapon.sightHeightCM, unit: .centimeters),
            vitalSize: Measurement(value: vitalDiameterCM, unit: .centimeters)
        )

        switch result {
        case .success(let pbr):
            return pbr
        case .failure:
            return nil
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header info card
            VStack(spacing: 6) {
                Text("DISTANCE DE RÉGLAGE OPTIMALE (DRO / PBR)")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.secondary)
                Text("Tir Tendu en Zone Vitale")
                    .font(.title2)
                    .bold()
            }
            .padding(.top, 8)

            // Target Size Selector
            VStack(alignment: .leading, spacing: 8) {
                Text("Diamètre de la zone vitale (Cible)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("Taille de cible", selection: $vitalDiameterCM) {
                    ForEach(presetVitalSizes, id: \.self) { size in
                        Text("\(Int(size)) cm (±\(Int(size / 2)) cm)").tag(size)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)

            if let pbr = pbrResult {
                let maxPBRMeters = Int(Double(pbr.maxPBRYards) * 0.9144)
                let farZeroMeters = Int(Double(pbr.farZeroYards) * 0.9144)
                let nearZeroMeters = Int(Double(pbr.nearZeroYards) * 0.9144)
                let offset100CM = Double(pbr.sightInAt100Yards) * 0.0254

                // Hero Result Card
                VStack(spacing: 12) {
                    Text("PORTÉE MAXIMALE SANS CORRECTION")
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.green)

                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(maxPBRMeters)")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundStyle(.green)
                        Text("mètres")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.secondary)
                    }

                    Text("De 0 à \(maxPBRMeters) m, visez plein centre : la balle restera dans la cible de \(Int(vitalDiameterCM)) cm sans toucher aux tourelles.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // Breakdown Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    PBRMetricCard(
                        title: "Zérotage Optimal",
                        value: "\(farZeroMeters) m",
                        subtitle: "Distance de réglage idéale",
                        color: .blue
                    )

                    PBRMetricCard(
                        title: "Hausse à 100 m",
                        value: "\(offset100CM >= 0 ? "+" : "")\(offset100CM.formatted(.number.precision(.fractionLength(1)))) cm",
                        subtitle: "Impact visé à 100 m",
                        color: .orange
                    )

                    PBRMetricCard(
                        title: "1er Zéro (Montée)",
                        value: "\(nearZeroMeters) m",
                        subtitle: "Premier croisement",
                        color: .purple
                    )

                    PBRMetricCard(
                        title: "Zone de Flèche",
                        value: "±\(Int(vitalDiameterCM / 2)) cm",
                        subtitle: "Tolérance max d'impact",
                        color: .teal
                    )
                }
                .padding(.horizontal)
            } else {
                ContentUnavailableView(
                    "Calcul impossible",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Vérifiez les paramètres de vitesse et de hauteur de visée de l'arme.")
                )
            }

            Spacer()
        }
    }
}

// MARK: - Subview Struct

struct PBRMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .bold()
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .bold()
                .foregroundStyle(color)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
