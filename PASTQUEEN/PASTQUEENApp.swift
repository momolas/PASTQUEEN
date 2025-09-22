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
	
	@StateObject private var dataController = DataManager()

    var body: some Scene {
        WindowGroup {
            LaunchView()
				.environment(\.managedObjectContext, dataController.persistentContainer.viewContext)
        }
		.modelContainer(for: Ballistics.self)
    }
}
