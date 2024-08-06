//
//  LOTO3App.swift
//  LOTO3
//
//  Created by Kyle Schang on 8/5/24.
//

import SwiftUI
import SwiftData

@main
struct LOTO3App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LOTO.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            LOTOAddView()
        }
        .modelContainer(sharedModelContainer)
    }
}
