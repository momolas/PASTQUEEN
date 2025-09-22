//
//  SwiftUIView4.swift
//  PASTQUEEN
//
//  Created by Mo on 10/06/2024.
//

import SwiftUI

struct BalisticsCalculatorView: View {
    @State private var distance: Double = 1000.0
    @State private var windSpeed: Double = 10.0
    @State private var windDirection: Double = 45.0
    @State private var temperature: Double = 15.0
    @State private var altitude: Double = 500.0
    
    @State private var muzzleVelocity: Double = 850.0
    @State private var projectileMass: Double = 10.0
    @State private var ballisticCoefficient: Double = 0.275
    
    @State private var driftCorrection: Double = 0.0
    @State private var elevationCorrection: Double = 0.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ballistics Calculator")
                .font(.title)
                .bold()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Target Distance")
                Slider(value: $distance, in: 0...2000, step: 50)
                    .padding(.horizontal)
                Text("\(distance, specifier: "%.0f") meters")
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Wind Speed and Direction")
                HStack {
                    Slider(value: $windSpeed, in: 0...30, step: 1)
                        .padding(.horizontal)
                    Text("\(windSpeed, specifier: "%.0f") km/h")
                }
                Slider(value: $windDirection, in: 0...360, step: 5)
                    .padding(.horizontal)
                Text("\(windDirection, specifier: "%.0f")°")
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Temperature and Altitude")
                HStack {
                    Slider(value: $temperature, in: -20...50, step: 1)
                        .padding(.horizontal)
                    Text("\(temperature, specifier: "%.0f")°C")
                }
                Slider(value: $altitude, in: 0...2000, step: 50)
                    .padding(.horizontal)
                Text("\(altitude, specifier: "%.0f") meters")
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Weapon and Projectile")
                HStack {
                    Slider(value: $muzzleVelocity, in: 600...1200, step: 10)
                        .padding(.horizontal)
                    Text("\(muzzleVelocity, specifier: "%.0f") m/s")
                }
                HStack {
                    Slider(value: $projectileMass, in: 5...20, step: 1)
                        .padding(.horizontal)
                    Text("\(projectileMass, specifier: "%.1f") g")
                }
                Slider(value: $ballisticCoefficient, in: 0.1...0.5, step: 0.01)
                    .padding(.horizontal)
                Text("BC: \(ballisticCoefficient, specifier: "%.3f")")
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Corrections")
                Text("Drift Correction: \(driftCorrection, specifier: "%.2f") m")
                Text("Elevation Correction: \(elevationCorrection, specifier: "%.2f") m")
            }
            
            Spacer()
        }
        .padding()
        .onChange(of: [distance, windSpeed, windDirection, temperature, altitude, muzzleVelocity, projectileMass, ballisticCoefficient]) {
            calculateBallistics()
        }
    }
    
    func calculateBallistics() {
        // Implement the ballistics calculation logic here
        let windSpeedPerp = windSpeed * sin(windDirection * Double.pi / 180)
        driftCorrection = windSpeedPerp * (distance / muzzleVelocity)
        
        let altitudeFactor = 1 + (altitude / 1000)
        let temperatureFactor = 1 - (temperature - 15) / 120
        let totalFactor = altitudeFactor * temperatureFactor
        elevationCorrection = totalFactor * (distance / 1000)
    }
}

#Preview {
    BalisticsCalculatorView()
}
