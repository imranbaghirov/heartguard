import CoreMotion
import Observation

/// Pedometer (steps, distance, floors, pace, cadence) and motion activity classification.
@Observable
final class ActivitySensors {
    var steps: Int?
    var distance: Double?
    var floorsAscended: Int?
    var floorsDescended: Int?
    var currentPace: Double?   // seconds per meter
    var currentCadence: Double? // steps per second
    var averageActivePace: Double?
    var pedometerError: String?

    var activities: [String] = []
    var activityConfidence = "—"
    var activityStart: Date?

    @ObservationIgnored private let pedometer = CMPedometer()
    @ObservationIgnored private let activityManager = CMMotionActivityManager()

    var stepCountingAvailable: Bool { CMPedometer.isStepCountingAvailable() }
    var distanceAvailable: Bool { CMPedometer.isDistanceAvailable() }
    var floorCountingAvailable: Bool { CMPedometer.isFloorCountingAvailable() }
    var activityAvailable: Bool { CMMotionActivityManager.isActivityAvailable() }

    func start() {
        let startOfDay = Calendar.current.startOfDay(for: .now)

        if stepCountingAvailable {
            pedometer.startUpdates(from: startOfDay) { [weak self] data, error in
                DispatchQueue.main.async {
                    self?.apply(data: data, error: error)
                }
            }
        }

        if activityAvailable {
            activityManager.startActivityUpdates(to: .main) { [weak self] activity in
                guard let self, let activity else { return }
                apply(activity: activity)
            }
        }
    }

    func stop() {
        pedometer.stopUpdates()
        activityManager.stopActivityUpdates()
    }

    private func apply(data: CMPedometerData?, error: Error?) {
        if let error {
            pedometerError = error.localizedDescription
            return
        }
        guard let data else { return }
        pedometerError = nil
        steps = data.numberOfSteps.intValue
        distance = data.distance?.doubleValue
        floorsAscended = data.floorsAscended?.intValue
        floorsDescended = data.floorsDescended?.intValue
        currentPace = data.currentPace?.doubleValue
        currentCadence = data.currentCadence?.doubleValue
        averageActivePace = data.averageActivePace?.doubleValue
    }

    private func apply(activity: CMMotionActivity) {
        var names: [String] = []
        if activity.stationary { names.append("Stationary") }
        if activity.walking { names.append("Walking") }
        if activity.running { names.append("Running") }
        if activity.cycling { names.append("Cycling") }
        if activity.automotive { names.append("Automotive") }
        if activity.unknown { names.append("Unknown") }
        activities = names
        activityStart = activity.startDate
        switch activity.confidence {
        case .low: activityConfidence = "Low"
        case .medium: activityConfidence = "Medium"
        case .high: activityConfidence = "High"
        @unknown default: activityConfidence = "—"
        }
    }
}
