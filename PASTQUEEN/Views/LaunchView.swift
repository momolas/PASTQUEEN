//
//  LaunchView.swift
//  PASTQUEEN
//
//  Created by Mo on 16/09/2022.
//

import SwiftUI
import SwiftData

struct LaunchView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                Text("PASTQUEEN")
                    .font(.largeTitle)

                Text("Another Ballistic Calculator")
                    .font(.caption)

                Spacer()

                NavigationLink(destination: AmmunitionView()) {
                    Image(systemName: "target")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.green)
                        .frame(width: 200, height: 200)
                }

                Spacer()
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Welcome")
        }
    }
}

#Preview {
	LaunchView()
		.preferredColorScheme(.dark)
		.modelContainer(for: BallisticSettings.self, inMemory: true)
}
