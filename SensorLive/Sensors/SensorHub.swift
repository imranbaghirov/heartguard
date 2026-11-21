import Foundation
import Observation

/// Owns every sensor and starts/stops them together.
@Observable
final class SensorHub {
    let motion = MotionSensors()
    let barometer = BarometerSensor()
    let location = LocationSensor()
    let activity = ActivitySensors()
    let device = DeviceSensors()
    let audio = AudioSensor()

    static let sampleRates: [Double] = [10, 30, 60, 100]

    private(set) var sampleRate: Double = 30
    private(set) var isRunning = false

    func setSampleRate(_ rate: Double) {
        sampleRate = rate
        guard isRunning else { return }
        motion.stop()
        motion.start(rate: rate)
    }

    func startAll() {
        guard !isRunning else { return }
        isRunning = true
        motion.start(rate: sampleRate)
        barometer.start()
        location.start()
        activity.start()
        device.start()
    }

    func stopAll() {
        guard isRunning else { return }
        isRunning = false
        motion.stop()
        barometer.stop()
        location.stop()
        activity.stop()
        device.stop()
        audio.stop()
    }
}
