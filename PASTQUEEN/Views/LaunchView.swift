//
//  LaunchView.swift
//  PASTQUEEN
//
//  Created by Mo on 16/09/2022.
//

import SwiftUI

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

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
            .preferredColorScheme(.dark)
    }
}