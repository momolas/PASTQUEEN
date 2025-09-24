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
    var body: some Scene {
        WindowGroup {
            // The main view could be a TabView to switch between Ammunition and Weather, for instance.
            // For now, we'll keep LaunchView as the entry point.
            LaunchView()
        }
        .modelContainer(for: Ballistics.self)
    }
}