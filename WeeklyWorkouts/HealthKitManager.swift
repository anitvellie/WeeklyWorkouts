//
//  HealthKitManager.swift
//  WeeklyWorkouts
//
//  Created by Alevtina Anishchenko on 18/01/2026.
//

import Combine
import Foundation
import HealthKit

@MainActor
final class HealthKitManager: ObservableObject {

    private let healthStore = HKHealthStore()

    @Published private(set) var workouts: [HKWorkout] = []

    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard isHealthDataAvailable else {
            throw NSError(domain: "HealthKit",
                          code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Health data not available on this device."])
        }

        // Read permissions: workouts + (optionally) quantities you may want to show in the list
        var readTypes: Set<HKObjectType> = [HKObjectType.workoutType()]
        if let energy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
            readTypes.insert(energy)
        }
        if let distance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) {
            readTypes.insert(distance)
        }

        try await healthStore.requestAuthorization(toShare: [], read: readTypes)
    }

    func refreshThisWeeksWorkouts() async throws {
        let now = Date()
        guard let week = Calendar.current.dateInterval(of: .weekOfYear, for: now) else { return }

        let predicate = HKQuery.predicateForSamples(withStart: week.start, end: now, options: .strictStartDate)

        // Async HealthKit query (iOS 17+)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.workout(predicate)],
            sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)],
            limit: HKObjectQueryNoLimit
        )

        let workouts = try await descriptor.result(for: healthStore)

        self.workouts = workouts
    }
}
