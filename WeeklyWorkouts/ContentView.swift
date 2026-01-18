//
//  ContentView.swift
//  WeeklyWorkouts
//
//  Created by Alevtina Anishchenko on 18/01/2026.
//

import HealthKit
import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var healthKitManager: HealthKitManager

    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if let errorMessage {
                    VStack(spacing: 12) {
                        Text("Health Access Issue")
                            .font(.headline)
                        Text(errorMessage)
                            .foregroundStyle(.secondary)
                        Button("Try Again") {
                            Task { await authorizeAndLoad() }
                        }
                    }
                    .padding()
                } else if healthKitManager.workouts.isEmpty {
                    ContentUnavailableView(
                        "No Workouts Yet",
                        systemImage: "figure.run",
                        description: Text("Workouts from this week will appear here.")
                    )
                } else {
                    List(healthKitManager.workouts, id: \.uuid) { workout in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(activityName(for: workout.workoutActivityType))
                                .font(.headline)
                            Text("\(formattedDate(workout.startDate)) • \(formattedDuration(workout.duration))")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("This Week")
        }
        .task {
            await authorizeAndLoad()
        }
    }

    private func authorizeAndLoad() async {
        do {
            try await healthKitManager.requestAuthorization()
            try await healthKitManager.refreshThisWeeksWorkouts()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func activityName(for type: HKWorkoutActivityType) -> String {
        // A simple, developer-facing label
        String(describing: type)
    }

    private func formattedDate(_ date: Date) -> String {
        DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        let seconds = Int(duration) % 60
        return String(format: "%dm %02ds", minutes, seconds)
    }
}

#Preview {
    ContentView()
        .environmentObject(HealthKitManager())
}
