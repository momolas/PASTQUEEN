//
//  SwiftUIView2.swift
//  PASTQUEEN
//
//  Created by Mo on 31/03/2023.
//

import SwiftUI

struct BallisticCalculatorView: View {
    // Input variables
    @State private var distance = ""
    @State private var windSpeed = ""
    @State private var windDirection = ""
    @State private var temperature = ""
    @State private var humidity = ""
    @State private var altitude = ""
    @State private var barometricPressure = ""
    
    // Output variables
    @State private var bulletDrop = ""
    @State private var windDrift = ""
    @State private var timeOfFlight = ""
    @State private var energy = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Input")) {
                    TextField("Distance (m)", text: $distance)
                        .keyboardType(.numberPad)
                    TextField("Wind speed (km/h)", text: $windSpeed)
                        .keyboardType(.numberPad)
                    TextField("Wind direction (degrees)", text: $windDirection)
                        .keyboardType(.numberPad)
                    TextField("Temperature (°C)", text: $temperature)
                        .keyboardType(.numberPad)
                    TextField("Humidity (%)", text: $humidity)
                        .keyboardType(.numberPad)
                    TextField("Altitude (m)", text: $altitude)
                        .keyboardType(.numberPad)
                    TextField("Barometric pressure (inHg)", text: $barometricPressure)
                        .keyboardType(.numberPad)
                }
                Section(header: Text("Output")) {
                    Text("Bullet drop: \(bulletDrop) cm")
                    Text("Wind drift: \(windDrift) cm")
                    Text("Time of flight: \(timeOfFlight) s")
                    Text("Energy: \(energy) kJ")
                }
            }
            .navigationTitle("Ballistic Calculator")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Calculate") {
                        calculateBallistics()
                    }
                }
            }
        }
    }
    
    func calculateBallistics() {
        // TODO: Implement ballistic calculation logic
    }
}

#Preview {
	BallisticCalculatorView()
		.preferredColorScheme(.dark)
}
