//
//  ReticleView.swift
//  PASTQUEEN
//

import SwiftUI
import Ballistics

struct ReticleView: View {
    let result: TrajectoryResult
    let scopeUnit: ScopeClickUnit
    let distanceMeters: Double

    @State private var zoomLevel: Double = 1.0

    private var elevationHoldoverUnits: Double {
        switch scopeUnit {
        case .mrad10:
            // Convert MOA to MIL
            return result.totalDropCorrectionMOA / 3.43774677
        case .moa14, .moa18:
            return result.totalDropCorrectionMOA
        }
    }

    private var windageHoldoverUnits: Double {
        switch scopeUnit {
        case .mrad10:
            return result.totalWindageCorrectionMOA / 3.43774677
        case .moa14, .moa18:
            return result.totalWindageCorrectionMOA
        }
    }

    private var unitLabel: String {
        switch scopeUnit {
        case .mrad10: return "MIL"
        case .moa14, .moa18: return "MOA"
        }
    }

    private var dropClicks: Int {
        scopeUnit.clicks(forMOACorrection: result.totalDropCorrectionMOA)
    }

    private var windageClicks: Int {
        scopeUnit.clicks(forMOACorrection: result.totalWindageCorrectionMOA)
    }

    private var windageDirection: String {
        result.totalWindageCorrectionMOA >= 0 ? "D" : "G"
    }

    var body: some View {
        VStack(spacing: 16) {
            // Quick-HUD Hero Header
            VStack(spacing: 4) {
                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text("\(Int(distanceMeters))")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("mètres")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.secondary)
                }

                if abs(result.movingTargetLeadCM) > 0.1 {
                    HStack(spacing: 4) {
                        Image(systemName: "figure.run")
                        Text("Cible Mobile : Avance \(abs(result.movingTargetLeadCM), format: .number.precision(.fractionLength(0))) cm (\(abs(result.movingTargetLeadMOA), format: .number.precision(.fractionLength(1))) MOA)")
                    }
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(.cyan)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.cyan.opacity(0.15), in: Capsule())
                }
            }

            // Quick-HUD Massive Badges
            HStack(spacing: 12) {
                // Elevation Badge
                VStack(spacing: 2) {
                    Text("ÉLÉVATION")
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.blue)

                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundStyle(.blue)
                        Text("\(dropClicks) clics")
                            .font(.title2)
                            .bold()
                            .fontDesign(.rounded)
                    }

                    Text("\(elevationHoldoverUnits, format: .number.precision(.fractionLength(1))) \(unitLabel)")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))

                // Windage / Lead Badge
                VStack(spacing: 2) {
                    Text("DÉRIVE / AVANCE")
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.orange)

                    HStack(spacing: 4) {
                        Image(systemName: windageDirection == "D" ? "arrow.right.circle.fill" : "arrow.left.circle.fill")
                            .foregroundStyle(.orange)
                        Text("\(windageClicks) clics \(windageDirection)")
                            .font(.title2)
                            .bold()
                            .fontDesign(.rounded)
                    }

                    Text("\(abs(windageHoldoverUnits), format: .number.precision(.fractionLength(1))) \(unitLabel)")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)


            // Graphical Scope Canvas
            ZStack {
                // Scope Outer Bezel
                Circle()
                    .fill(Color.black.opacity(0.92))
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.gray.opacity(0.6), .gray.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 6
                            )
                    )
                    .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 6)

                // Tactical Reticle Grid
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let maxRadius = size.width / 2 - 10
                    let step: CGFloat = 20.0 * zoomLevel

                    // Main Crosshairs
                    var hPath = Path()
                    hPath.move(to: CGPoint(x: center.x - maxRadius, y: center.y))
                    hPath.addLine(to: CGPoint(x: center.x + maxRadius, y: center.y))

                    var vPath = Path()
                    vPath.move(to: CGPoint(x: center.x, y: center.y - maxRadius))
                    vPath.addLine(to: CGPoint(x: center.x, y: center.y + maxRadius))

                    context.stroke(hPath, with: .color(.white.opacity(0.7)), lineWidth: 1.5)
                    context.stroke(vPath, with: .color(.white.opacity(0.7)), lineWidth: 1.5)

                    // Subtension Hash Marks
                    for i in 1...12 {
                        let offset = CGFloat(i) * step
                        let isMajor = (i % 2 == 0)
                        let tickLen: CGFloat = isMajor ? 8.0 : 4.0

                        // Vertical (Elevation marks)
                        if center.y + offset < size.height - 15 {
                            var tick = Path()
                            tick.move(to: CGPoint(x: center.x - tickLen, y: center.y + offset))
                            tick.addLine(to: CGPoint(x: center.x + tickLen, y: center.y + offset))
                            context.stroke(tick, with: .color(.white.opacity(0.6)), lineWidth: 1.0)
                        }

                        if center.y - offset > 15 {
                            var tick = Path()
                            tick.move(to: CGPoint(x: center.x - tickLen, y: center.y - offset))
                            tick.addLine(to: CGPoint(x: center.x + tickLen, y: center.y - offset))
                            context.stroke(tick, with: .color(.white.opacity(0.6)), lineWidth: 1.0)
                        }

                        // Horizontal (Windage marks)
                        if center.x + offset < size.width - 15 {
                            var tick = Path()
                            tick.move(to: CGPoint(x: center.x + offset, y: center.y - tickLen))
                            tick.addLine(to: CGPoint(x: center.x + offset, y: center.y + tickLen))
                            context.stroke(tick, with: .color(.white.opacity(0.6)), lineWidth: 1.0)
                        }

                        if center.x - offset > 15 {
                            var tick = Path()
                            tick.move(to: CGPoint(x: center.x - offset, y: center.y - tickLen))
                            tick.addLine(to: CGPoint(x: center.x - offset, y: center.y + tickLen))
                            context.stroke(tick, with: .color(.white.opacity(0.6)), lineWidth: 1.0)
                        }
                    }
                }

                // Dynamic Illuminated Holdover Point (Point d'impact)
                GeometryReader { geo in
                    let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                    let step: CGFloat = 20.0 * zoomLevel

                    // In a rifle scope reticle:
                    // Drop requires aiming ABOVE target -> reticle holdover mark is DOWN (positive y in canvas)
                    // Wind to the right requires aiming LEFT -> reticle mark is LEFT (negative x in canvas)
                    let targetX = center.x - CGFloat(windageHoldoverUnits) * step
                    let targetY = center.y + CGFloat(elevationHoldoverUnits) * step

                    let clampedX = min(max(targetX, 25), geo.size.width - 25)
                    let clampedY = min(max(targetY, 25), geo.size.height - 25)

                    ZStack {
                        // Halo glow
                        Circle()
                            .fill(Color.red.opacity(0.35))
                            .frame(width: 22, height: 22)

                        // Center Red Dot
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .shadow(color: .red, radius: 4)

                        // Subtitle Callout
                        VStack(spacing: 1) {
                            Text("VISER ICI")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.red)
                            Text("\(Int(distanceMeters)) m")
                                .font(.system(size: 7, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        .offset(x: 28, y: -8)
                    }
                    .position(x: clampedX, y: clampedY)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: [elevationHoldoverUnits, windageHoldoverUnits])
                }
            }
            .frame(width: 320, height: 320)
            .padding()

            // Instructions text
            Text("Placez le point rouge illuminé sur le centre de votre cible pour compenser immédiatement la chute et le vent.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.vertical)
    }
}
