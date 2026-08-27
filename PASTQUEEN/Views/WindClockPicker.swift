//
//  WindClockPicker.swift
//  PASTQUEEN
//

import SwiftUI

struct WindClockPicker: View {
    @Binding var windDirectionDegrees: Double
    
    private var currentHour: Int {
        let normalized = Int(round(windDirectionDegrees / 30.0)) % 12
        return normalized == 0 ? 12 : normalized
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(.windDirection)
                Spacer()
                Text("\(currentHour) h (\(Text("\(Int(windDirectionDegrees))°").bold().foregroundStyle(.blue)))")
            }
            .fontDesign(.rounded)
            
            ZStack {
                Circle()
                    .stroke(.secondary.opacity(0.3), lineWidth: 4)
                    .background(Circle().fill(.ultraThinMaterial))
                    .frame(width: 140, height: 140)
                
                // Hour markings around the circle
                ForEach(1...12, id: \.self) { hour in
                    let angle = Double(hour) * 30.0 - 90.0
                    Text("\(hour)")
                        .font(.system(.footnote, design: .rounded))
                        .bold()
                        .foregroundStyle(currentHour == hour ? .blue : .secondary)
                        .position(
                            x: 70 + 50 * cos(angle * .pi / 180.0),
                            y: 70 + 50 * sin(angle * .pi / 180.0)
                        )
                }
                
                // Directional needle indicator
                Image(systemName: "arrow.up")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.blue)
                    .rotationEffect(.degrees(windDirectionDegrees))
                    .shadow(color: .blue.opacity(0.4), radius: 6)
            }
            .frame(width: 140, height: 140)
            .contentShape(.circle)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let vector = CGVector(dx: value.location.x - 70, dy: value.location.y - 70)
                        let radians = atan2(vector.dy, vector.dx)
                        var degrees = radians * 180.0 / .pi + 90.0
                        if degrees < 0 { degrees += 360.0 }
                        
                        // Snap to hour increments (30 degrees each)
                        let hour = Int(round(degrees / 30.0)) % 12
                        windDirectionDegrees = Double(hour) * 30.0
                    }
            )
        }
        .padding(.vertical, 8)
        .sensoryFeedback(.selection, trigger: currentHour)
    }
}


#Preview {
    @Previewable @State var windAngle = 90.0
    Form {
        Section {
            WindClockPicker(windDirectionDegrees: $windAngle)
        }
    }
    .preferredColorScheme(.dark)
}
