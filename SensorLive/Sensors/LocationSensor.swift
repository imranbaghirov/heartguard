import CoreLocation
import Observation

/// GPS / GNSS position and compass heading.
@Observable
final class LocationSensor: NSObject, CLLocationManagerDelegate {
    var authorization: CLAuthorizationStatus = .notDetermined
    var location: CLLocation?
    var heading: CLHeading?
    var error: String?

    @ObservationIgnored private let manager = CLLocationManager()
    @ObservationIgnored private var wantsUpdates = false

    var headingAvailable: Bool { CLLocationManager.headingAvailable() }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.headingFilter = 1
        authorization = manager.authorizationStatus
    }

    func start() {
        wantsUpdates = true
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        beginIfAuthorized()
    }

    func stop() {
        wantsUpdates = false
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }

    private func beginIfAuthorized() {
        guard wantsUpdates else { return }
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
            if CLLocationManager.headingAvailable() {
                manager.startUpdatingHeading()
            }
        default:
            break
        }
    }

    // MARK: CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorization = manager.authorizationStatus
        beginIfAuthorized()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        error = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError, clError.code == .locationUnknown { return }
        self.error = error.localizedDescription
    }

    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        true
    }
}

extension CLAuthorizationStatus {
    var label: String {
        switch self {
        case .notDetermined: "Not requested"
        case .restricted: "Restricted"
        case .denied: "Denied"
        case .authorizedAlways: "Always"
        case .authorizedWhenInUse: "While using"
        @unknown default: "Unknown"
        }
    }

    var isAuthorized: Bool { self == .authorizedAlways || self == .authorizedWhenInUse }
}
