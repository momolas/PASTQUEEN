//
//  ContentView.swift
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
				
				Text("Une application pour faire des calculs balistiques")
					.font(.caption)
				
				Spacer()
				
				NavigationLink(destination: SwiftUIView(), label: { Image(systemName: "target")
						.renderingMode(.original)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.foregroundColor(.green)
						.frame(width: 200, height: 200)
				})
				
				Spacer()
				Spacer()
			}
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

#Preview {
	LaunchView()
		.preferredColorScheme(.dark)
		//.environment(\.managedObjectContext, dataController.container.viewContext)
}
