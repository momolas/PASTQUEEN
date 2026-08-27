//
//  WindClockPicker.swift
//  PASTQUEEN
//
//  Created by Mo on 27/08/2026.
//

import SwiftUI

struct WindClockPicker: View {
    @Binding var windDirectionDegrees: Double

    private var currentHour: Int {
        let normalized = Int(round(windDirectionDegrees / 30.0)) % 12
        return normalized == 0 ? 12 : normalized
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Label("Direction du Vent", systemImage: "wind")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(currentHour)h • \(Int(windDirectionDegrees))°")
                    .font(.subheadline)
                    .bold()
                    .fontDesign(.rounded)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.18), in: Capsule())
                    .foregroundStyle(.blue)
            }

            ZStack {
                // Outer Dial
                Circle()
                    .fill(Color.black.opacity(0.6))
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.2), Color.white.opacity(0.04)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .frame(width: 170, height: 170)

                // Sub-markings
                ForEach(1...12, id: \.self) { hour in
                    let angle = Double(hour) * 30.0 - 90.0
                    let isSelected = (currentHour == hour)

                    Text("\(hour)")
                        .font(.system(size: isSelected ? 13 : 11, weight: isSelected ? .bold : .medium, design: .rounded))
                        .foregroundStyle(isSelected ? .white : .secondary.opacity(0.7))
                        .position(
                            x: 85 + 62 * cos(angle * .pi / 180.0),
                            y: 85 + 62 * sin(angle * .pi / 180.0)
                        )
                }

                // Center Wind Direction Pointer
                ZStack {
                    // Needle trail
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 4, height: 44)
                        .offset(y: -22)

                    // Needle Head
                    Image(systemName: "arrowtriangle.up.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.blue)
                        .offset(y: -44)
                        .shadow(color: .blue, radius: 4)

                    // Center Pivot
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                        .shadow(color: .black.opacity(0.5), radius: 2)
                }
                .rotationEffect(.degrees(windDirectionDegrees))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: windDirectionDegrees)
            }
            .frame(width: 170, height: 170)
            .contentShape(.circle)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let vector = CGVector(dx: value.location.x - 85, dy: value.location.y - 85)
                        let radians = atan2(vector.dy, vector.dx)
                        var degrees = radians * 180.0 / .pi + 90.0
                        if degrees < 0 { degrees += 360.0 }

                        let hour = Int(round(degrees / 30.0)) % 12
                        windDirectionDegrees = Double(hour) * 30.0
                    }
            )
        }
        .padding(.vertical, 6)
        .sensoryFeedback(.selection, trigger: currentHour)
    }
}
