//
//  PBRView.swift
//  PASTQUEEN
//
//  Created by Mo on 27/08/2026.
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
        ScrollView {
            VStack(spacing: 16) {
                // Vital Zone Size Picker
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Zone Vitale (Cible)", systemImage: "target")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("±\(Int(vitalDiameterCM / 2)) cm")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.green)
                    }

                    Picker("Taille de cible", selection: $vitalDiameterCM) {
                        ForEach(presetVitalSizes, id: \.self) { size in
                            Text("\(Int(size)) cm").tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                    .sensoryFeedback(.selection, trigger: vitalDiameterCM)
                }
                .padding(.horizontal)
                .padding(.top, 6)

                if let pbr = pbrResult {
                    let maxPBRMeters = Int(Double(pbr.maxPBRYards) * 0.9144)
                    let farZeroMeters = Int(Double(pbr.farZeroYards) * 0.9144)
                    let nearZeroMeters = Int(Double(pbr.nearZeroYards) * 0.9144)
                    let offset100CM = Double(pbr.sightInAt100Yards) * 0.0254

                    // Hero Result Card
                    VStack(spacing: 8) {
                        Text("PORTÉE MAXIMALE SANS CORRECTION")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.green)

                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(maxPBRMeters)")
                                .font(.system(size: 52, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("m")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.green)
                        }

                        Text("De 0 à \(maxPBRMeters) m, visez plein centre : l'impact reste dans la zone de \(Int(vitalDiameterCM)) cm.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .padding(.horizontal, 14)
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                    .padding(.horizontal)

                    // Breakdown Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        PBRMetricCard(
                            title: "DRO (RÉGLAGE IDÉAL)",
                            value: "\(farZeroMeters) m",
                            subtitle: "Distance du 2nd zéro",
                            color: .blue
                        )

                        PBRMetricCard(
                            title: "HAUSSE À 100 M",
                            value: "\(offset100CM >= 0 ? "+" : "")\(offset100CM.formatted(.number.precision(.fractionLength(1)))) cm",
                            subtitle: "Point d'impact visé",
                            color: .orange
                        )

                        PBRMetricCard(
                            title: "1ER ZÉRO (MONTÉE)",
                            value: "\(nearZeroMeters) m",
                            subtitle: "Premier croisement",
                            color: .purple
                        )

                        PBRMetricCard(
                            title: "FLÈCHE MAX",
                            value: "±\(Int(vitalDiameterCM / 2)) cm",
                            subtitle: "Écart haut/bas max",
                            color: .cyan
                        )
                    }
                    .padding(.horizontal)
                } else {
                    ContentUnavailableView(
                        "Calcul indisponible",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Vérifiez les paramètres de vitesse et de hauteur de visée.")
                    )
                    .padding(.top, 40)
                }
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Tir Tendu (DRO)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subview Struct

struct PBRMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .bold()
                .fontDesign(.rounded)
                .foregroundStyle(color)
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
    }
}
