import SwiftUI
import CoreLocation

struct GPSCard: View {
    let location: LocationSensor

    var body: some View {
        SensorCard(title: "GPS / Location", symbol: "location.fill", tint: .blue, status: location.authorization.label) {
            if let loc = location.location {
                Group {
                    ValueRow(label: "Latitude", value: loc.coordinate.latitude.fixed(6) + "°")
                    ValueRow(label: "Longitude", value: loc.coordinate.longitude.fixed(6) + "°")
                    ValueRow(label: "Horizontal accuracy", value: accuracy(loc.horizontalAccuracy))
                    Divider()
                    ValueRow(label: "Altitude (MSL)", value: "\(loc.altitude.fixed(1)) m")
                    ValueRow(label: "Ellipsoidal altitude", value: "\(loc.ellipsoidalAltitude.fixed(1)) m")
                    ValueRow(label: "Vertical accuracy", value: accuracy(loc.verticalAccuracy))
                }
                Divider()
                Group {
                    ValueRow(label: "Speed", value: speed(loc))
                    ValueRow(label: "Speed accuracy", value: loc.speedAccuracy >= 0 ? "±\(loc.speedAccuracy.fixed(1)) m/s" : "—")
                    ValueRow(label: "Course", value: loc.course >= 0 ? "\(loc.course.fixed(1))°" : "—")
                    ValueRow(label: "Course accuracy", value: loc.courseAccuracy >= 0 ? "±\(loc.courseAccuracy.fixed(1))°" : "—")
                    if let floor = loc.floor {
                        ValueRow(label: "Floor", value: "\(floor.level)")
                    }
                }
                ValueRow(label: "Fix time", value: loc.timestamp.formatted(date: .omitted, time: .standard))
                if loc.sourceInformation?.isSimulatedBySoftware == true {
                    Text("Location is simulated").font(.caption).foregroundStyle(.orange)
                }
            } else if location.authorization == .denied || location.authorization == .restricted {
                UnavailableNote(text: "Location access is off. Enable it in Settings › Privacy › Location Services.")
            } else {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Waiting for a fix…").foregroundStyle(.secondary)
                }
            }
            if let error = location.error {
                Text(error).font(.caption).foregroundStyle(.red)
            }
        }
    }

    private func accuracy(_ value: CLLocationAccuracy) -> String {
        value >= 0 ? "±\(value.fixed(1)) m" : "invalid"
    }

    private func speed(_ loc: CLLocation) -> String {
        guard loc.speed >= 0 else { return "—" }
        return "\(loc.speed.fixed(2)) m/s · \((loc.speed * 3.6).fixed(1)) km/h"
    }
}

struct CompassCard: View {
    let location: LocationSensor

    var body: some View {
        SensorCard(title: "Compass", symbol: "safari", tint: .red) {
            if !location.headingAvailable {
                UnavailableNote()
            } else if let heading = location.heading {
                HStack {
                    Spacer()
                    CompassDial(heading: heading.trueHeading >= 0 ? heading.trueHeading : heading.magneticHeading)
                    Spacer()
                }
                ValueRow(label: "Magnetic heading", value: "\(heading.magneticHeading.fixed(1))°")
                ValueRow(label: "True heading", value: heading.trueHeading >= 0 ? "\(heading.trueHeading.fixed(1))°" : "needs location")
                ValueRow(label: "Accuracy", value: heading.headingAccuracy >= 0 ? "±\(heading.headingAccuracy.fixed(1))°" : "invalid")
                VectorReadout(vector: Vector3(x: heading.x, y: heading.y, z: heading.z), unit: "µT (geomagnetic)", digits: 1)
            } else {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Waiting for heading…").foregroundStyle(.secondary)
                }
            }
        }
    }
}
