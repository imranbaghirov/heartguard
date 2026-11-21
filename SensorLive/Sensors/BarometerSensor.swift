import CoreMotion
import Observation

/// Barometric pressure plus relative and absolute altitude from CMAltimeter.
@Observable
final class BarometerSensor {
    var pressureKPa: Double?
    var pressureHistory = TimeSeries<Double>()
    var relativeAltitude: Double?
    var absoluteAltitude: Double?
    var absoluteAccuracy: Double?
    var absolutePrecision: Double?
    var error: String?

    @ObservationIgnored private let altimeter = CMAltimeter()

    var relativeAvailable: Bool { CMAltimeter.isRelativeAltitudeAvailable() }
    var absoluteAvailable: Bool { CMAltimeter.isAbsoluteAltitudeAvailable() }

    func start() {
        if relativeAvailable {
            altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
                guard let self else { return }
                if let error { self.error = error.localizedDescription; return }
                guard let data else { return }
                let kPa = data.pressure.doubleValue
                pressureKPa = kPa
                pressureHistory.append(kPa * 10) // hPa
                relativeAltitude = data.relativeAltitude.doubleValue
            }
        }

        if absoluteAvailable {
            altimeter.startAbsoluteAltitudeUpdates(to: .main) { [weak self] data, error in
                guard let self else { return }
                if let error { self.error = error.localizedDescription; return }
                guard let data else { return }
                absoluteAltitude = data.altitude
                absoluteAccuracy = data.accuracy
                absolutePrecision = data.precision
            }
        }
    }

    func stop() {
        altimeter.stopRelativeAltitudeUpdates()
        altimeter.stopAbsoluteAltitudeUpdates()
    }
}
