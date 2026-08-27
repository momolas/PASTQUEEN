//
//  ReticleView.swift
//  PASTQUEEN
//
//  Created by Mo on 27/08/2026.
//

import SwiftUI
import Ballistics

struct ReticleView: View {
    let result: TrajectoryResult
    let scopeUnit: ScopeClickUnit
    let distanceMeters: Double
    var showHUD: Bool = false

    @State private var zoomLevel: Double = 1.0

    private var elevationHoldoverUnits: Double {
        switch scopeUnit {
        case .mrad10:
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
        VStack(spacing: 12) {
            if showHUD {
                // Standalone Quick-HUD Header (used in CalculatorView)
                VStack(spacing: 4) {
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(Int(distanceMeters))")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("m")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.secondary)
                    }

                    if abs(result.movingTargetLeadCM) > 0.1 {
                        HStack(spacing: 4) {
                            Image(systemName: "figure.run")
                            Text("Avance \(abs(result.movingTargetLeadCM), format: .number.precision(.fractionLength(0))) cm")
                        }
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.cyan)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.cyan.opacity(0.15), in: Capsule())
                    }
                }

                HStack(spacing: 10) {
                    VStack(spacing: 2) {
                        Text("ÉLÉVATION")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.blue)

                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundStyle(.blue)
                            Text("\(dropClicks) clics")
                                .font(.title3)
                                .bold()
                                .fontDesign(.rounded)
                        }

                        Text("\(elevationHoldoverUnits, format: .number.precision(.fractionLength(1))) \(unitLabel)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))

                    VStack(spacing: 2) {
                        Text("DÉRIVE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.orange)

                        HStack(spacing: 4) {
                            Image(systemName: windageDirection == "D" ? "arrow.right.circle.fill" : "arrow.left.circle.fill")
                                .foregroundStyle(.orange)
                            Text("\(windageClicks) clics \(windageDirection)")
                                .font(.title3)
                                .bold()
                                .fontDesign(.rounded)
                        }

                        Text("\(abs(windageHoldoverUnits), format: .number.precision(.fractionLength(1))) \(unitLabel)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                }
                .padding(.horizontal)
            }

            // Minimalist Optical Scope Canvas
            ZStack {
                // Scope Outer Bezel (Sleek dark titanium ring)
                Circle()
                    .fill(Color.black.opacity(0.85))
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: .black.opacity(0.5), radius: 14, x: 0, y: 6)

                // High-Precision Vector Reticle
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let maxRadius = size.width / 2 - 12
                    let step: CGFloat = 18.0 * zoomLevel

                    // Main Fine Crosshairs
                    var hPath = Path()
                    hPath.move(to: CGPoint(x: center.x - maxRadius, y: center.y))
                    hPath.addLine(to: CGPoint(x: center.x + maxRadius, y: center.y))

                    var vPath = Path()
                    vPath.move(to: CGPoint(x: center.x, y: center.y - maxRadius))
                    vPath.addLine(to: CGPoint(x: center.x, y: center.y + maxRadius))

                    context.stroke(hPath, with: .color(.white.opacity(0.55)), lineWidth: 1.0)
                    context.stroke(vPath, with: .color(.white.opacity(0.55)), lineWidth: 1.0)

                    // Subtension Hash Marks
                    for i in 1...14 {
                        let offset = CGFloat(i) * step
                        let isMajor = (i % 2 == 0)
                        let tickLen: CGFloat = isMajor ? 6.0 : 3.0

                        // Vertical (Elevation)
                        if center.y + offset < size.height - 18 {
                            var tick = Path()
                            tick.move(to: CGPoint(x: center.x - tickLen, y: center.y + offset))
                            tick.addLine(to: CGPoint(x: center.x + tickLen, y: center.y + offset))
                            context.stroke(tick, with: .color(.white.opacity(0.5)), lineWidth: 0.8)
                        }

                        if center.y - offset > 18 {
                            var tick = Path()
                            tick.move(to: CGPoint(x: center.x - tickLen, y: center.y - offset))
                            tick.addLine(to: CGPoint(x: center.x + tickLen, y: center.y - offset))
                            context.stroke(tick, with: .color(.white.opacity(0.5)), lineWidth: 0.8)
                        }

                        // Horizontal (Windage)
                        if center.x + offset < size.width - 18 {
                            var tick = Path()
                            tick.move(to: CGPoint(x: center.x + offset, y: center.y - tickLen))
                            tick.addLine(to: CGPoint(x: center.x + offset, y: center.y + tickLen))
                            context.stroke(tick, with: .color(.white.opacity(0.5)), lineWidth: 0.8)
                        }

                        if center.x - offset > 18 {
                            var tick = Path()
                            tick.move(to: CGPoint(x: center.x - offset, y: center.y - tickLen))
                            tick.addLine(to: CGPoint(x: center.x - offset, y: center.y + tickLen))
                            context.stroke(tick, with: .color(.white.opacity(0.5)), lineWidth: 0.8)
                        }
                    }

                    // Center Optical Ring
                    var ring = Path()
                    ring.addEllipse(in: CGRect(x: center.x - 3, y: center.y - 3, width: 6, height: 6))
                    context.stroke(ring, with: .color(.white.opacity(0.3)), lineWidth: 0.7)
                }

                // Dynamic Illuminated Holdover Point
                GeometryReader { geo in
                    let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                    let step: CGFloat = 18.0 * zoomLevel

                    let targetX = center.x - CGFloat(windageHoldoverUnits) * step
                    let targetY = center.y + CGFloat(elevationHoldoverUnits) * step

                    let clampedX = min(max(targetX, 22), geo.size.width - 22)
                    let clampedY = min(max(targetY, 22), geo.size.height - 22)

                    ZStack {
                        // Soft Red Laser Glow
                        Circle()
                            .fill(Color.red.opacity(0.28))
                            .frame(width: 18, height: 18)

                        // Center Red Impact Dot
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                            .shadow(color: .red, radius: 3)
                    }
                    .position(x: clampedX, y: clampedY)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: [elevationHoldoverUnits, windageHoldoverUnits])
                }
            }
            .frame(width: 300, height: 300)
            .padding(.vertical, 4)
        }
    }
}
