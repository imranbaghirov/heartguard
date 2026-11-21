import SwiftUI

struct PedometerCard: View {
    let activity: ActivitySensors

    var body: some View {
        SensorCard(title: "Pedometer", symbol: "shoeprints.fill", tint: .green, status: "today") {
            if activity.stepCountingAvailable {
                HStack(alignment: .firstTextBaseline) {
                    Text(activity.steps.map { "\($0)" } ?? "—")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                    Text("steps").foregroundStyle(.secondary)
                }
                if activity.distanceAvailable {
                    ValueRow(label: "Distance", value: activity.distance.map { "\(($0 / 1000).fixed(2)) km" } ?? "—")
                }
                if activity.floorCountingAvailable {
                    ValueRow(label: "Floors up / down",
                             value: "\(activity.floorsAscended.map { "\($0)" } ?? "—") / \(activity.floorsDescended.map { "\($0)" } ?? "—")")
                }
                ValueRow(label: "Current pace", value: pace(activity.currentPace))
                ValueRow(label: "Average active pace", value: pace(activity.averageActivePace))
                ValueRow(label: "Cadence", value: activity.currentCadence.map { "\(($0 * 60).fixed(0)) steps/min" } ?? "—")
                if let error = activity.pedometerError {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
            } else {
                UnavailableNote()
            }
        }
    }

    /// Converts seconds-per-meter into min/km.
    private func pace(_ secondsPerMeter: Double?) -> String {
        guard let s = secondsPerMeter, s > 0 else { return "—" }
        let perKm = s * 1000
        let minutes = Int(perKm) / 60
        let seconds = Int(perKm) % 60
        return String(format: "%d:%02d /km", minutes, seconds)
    }
}

struct MotionActivityCard: View {
    let activity: ActivitySensors

    var body: some View {
        SensorCard(title: "Motion Activity", symbol: "figure.run", tint: .mint, status: "confidence: \(activity.activityConfidence)") {
            if activity.activityAvailable {
                if activity.activities.isEmpty {
                    Text("Waiting for activity…").foregroundStyle(.secondary)
                } else {
                    HStack {
                        ForEach(activity.activities, id: \.self) { name in
                            Label(name, systemImage: symbol(for: name))
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.mint.opacity(0.18), in: Capsule())
                        }
                    }
                }
                if let start = activity.activityStart {
                    ValueRow(label: "Since", value: start.formatted(date: .omitted, time: .standard))
                }
            } else {
                UnavailableNote()
            }
        }
    }

    private func symbol(for name: String) -> String {
        switch name {
        case "Stationary": "figure.stand"
        case "Walking": "figure.walk"
        case "Running": "figure.run"
        case "Cycling": "figure.outdoor.cycle"
        case "Automotive": "car.fill"
        default: "questionmark"
        }
    }
}
