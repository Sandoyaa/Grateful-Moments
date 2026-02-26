//
//  DataContainer.swift
//  GratefulMoments
//
//  Created by Siyanie on 26.02.2026.
//

import SwiftData
import SwiftUI

@Observable
class DataContainer {
    let modelContainer: ModelContainer


    var context: ModelContext {
        modelContainer.mainContext
    }

    @MainActor
    init(includeSampleMoments: Bool = false) {
        let schema = Schema([
            Moment.self,
        ])


        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: includeSampleMoments)


        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])


            if includeSampleMoments {
                loadSampleMoments()
            }
            try context.save()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }


    private func loadSampleMoments() {
        for moment in Moment.sampleData {
            context.insert(moment)
        }
    }
}

private let sampleContainer = DataContainer(includeSampleMoments: true)

extension View {
    func sampleDataContainer() -> some View {
        self
            .environment(sampleContainer)
            .modelContainer(sampleContainer.modelContainer)
        
    }
}
