//
//  SwiftUIView.swift
//  PASTQUEEN
//
//  Created by Mo on 16/09/2022.
//

import SwiftUI
import SwiftData

struct AmmunitionView: View {
    @Query(sort: \BallisticSettings.ammunitionName) var ballistics: [BallisticSettings]
    @Environment(\.modelContext) var modelContext

    @State private var showingAddScreen = false

    func deleteAmmunitions(at offsets: IndexSet) {
        for offset in offsets {
            let ballisticSetting = ballistics[offset]
            modelContext.delete(ballisticSetting)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(ballistics) { ballisticSetting in
                    NavigationLink {
                        DetailView(ballisticSettings: ballisticSetting)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(ballisticSetting.ammunitionName)
                                .font(.headline)
                            Text(ballisticSetting.calibre)
                                .font(.subheadline)
                        }
                    }
                }
                .onDelete(perform: deleteAmmunitions)
            }
            .navigationTitle("Ammunition")
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
}

struct AmmunitionView_Previews: PreviewProvider {
    static var previews: some View {
        AmmunitionView()
            .modelContainer(for: BallisticSettings.self, inMemory: true)
    }
}