//
//  SwiftUIView.swift
//  PASTQUEEN
//
//  Created by Mo on 16/09/2022.
//

import SwiftUI
import CoreData

struct AmmunitionView: View {
	@FetchRequest(sortDescriptors: [SortDescriptor(\.calibre)]) var ballisticSettings: FetchedResults<BallisticSettings>
	
	@Environment(\.managedObjectContext) var viewContext
	@Environment(\.managedObjectContext) var moc
	
	@FocusState private var isFocused: Bool
	@State private var showingAddScreen = false
	
	func deleteAmmunitions(at offsets: IndexSet) {
		for offset in offsets {
			let ballisticSetting = ballisticSettings[offset]
			moc.delete(ballisticSetting)
		}
		//try? moc.save()
	}
	
	var body: some View {
		NavigationStack {
			List {
				ForEach(ballisticSettings) { ballisticSetting in
					NavigationLink {
						DetailView(ballisticSettings: ballisticSetting)
					} label: {
						VStack(alignment: .leading) {
							Text(ballisticSetting.ammunitionName ?? "NA")
								.font(.headline)
						}
					}
				}
				.onDelete(perform: deleteAmmunitions)
			}
		}
		.navigationTitle("Ammunition")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				EditButton()
			}
			
			ToolbarItem(placement: .navigationBarTrailing) {
				Button {
					showingAddScreen.toggle()
				} label: {
					Label("Add Ammunition", systemImage: "plus")
				}
			}
		}
		.sheet(isPresented: $showingAddScreen) {
			AddView()
		}
	}
}

struct inputView_Previews: PreviewProvider {
	static var previews: some View {
		AmmunitionView()
			.preferredColorScheme(.dark)
	}
}
