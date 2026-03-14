//
//  PASTQUEENApp.swift
//  PASTQUEEN
//
//  Created by Mo on 16/09/2022.
//

import SwiftUI
import SwiftData

@main
struct PASTQUEENApp: App {
    @State private var locationManager = LocationManager()
    @State private var weatherManager = WeatherManager()

    var body: some Scene {
        WindowGroup {
            LaunchView()
                .preferredColorScheme(.dark)
        }
        .environment(locationManager)
        .environment(weatherManager)
        .modelContainer(for: BallisticSettings.self)
    }
}