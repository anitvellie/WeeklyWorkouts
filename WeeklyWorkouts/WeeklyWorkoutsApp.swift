//
//  WeeklyWorkoutsApp.swift
//  WeeklyWorkouts
//
//  Created by Alevtina Anishchenko on 18/01/2026.
//

import SwiftUI
import SwiftData

@main
struct WeeklyWorkoutsApp: App {

    @StateObject private var healthKitManager = HealthKitManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
            ContentView()
                .environmentObject(healthKitManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
