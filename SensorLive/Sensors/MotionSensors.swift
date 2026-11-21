import CoreMotion
import Observation

/// Accelerometer, gyroscope, magnetometer and fused device-motion data.
@Observable
final class MotionSensors {
    // Raw sensors
    var acceleration = Vector3.zero
    var accelerationHistory = TimeSeries<Vector3>()
    var rotationRate = Vector3.zero
    var rotationHistory = TimeSeries<Vector3>()
    var magneticField = Vector3.zero
    var magneticHistory = TimeSeries<Vector3>()

    // Fused device motion
    var attitude = Vector3.zero // roll, pitch, yaw in degrees
    var attitudeHistory = TimeSeries<Vector3>()
    var quaternion = Quaternion.identity
    var gravity = Vector3(x: 0, y: 0, z: -1)
    var userAcceleration = Vector3.zero
    var userAccelerationHistory = TimeSeries<Vector3>()
    var unbiasedRotationRate = Vector3.zero
    var calibratedField = Vector3.zero
    var fieldAccuracy: CMMagneticFieldCalibrationAccuracy = .uncalibrated
    var heading: Double?
    var referenceFrame = "—"

    @ObservationIgnored private let manager = CMMotionManager()

    var accelerometerAvailable: Bool { manager.isAccelerometerAvailable }
    var gyroAvailable: Bool { manager.isGyroAvailable }
    var magnetometerAvailable: Bool { manager.isMagnetometerAvailable }
    var deviceMotionAvailable: Bool { manager.isDeviceMotionAvailable }

    func start(rate: Double) {
        let interval = 1.0 / rate

        if manager.isAccelerometerAvailable {
            manager.accelerometerUpdateInterval = interval
            manager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
                guard let self, let data else { return }
                let value = Vector3(data.acceleration)
                acceleration = value
                accelerationHistory.append(value)
            }
        }

        if manager.isGyroAvailable {
            manager.gyroUpdateInterval = interval
            manager.startGyroUpdates(to: .main) { [weak self] data, _ in
                guard let self, let data else { return }
                let value = Vector3(data.rotationRate)
                rotationRate = value
                rotationHistory.append(value)
            }
        }

        if manager.isMagnetometerAvailable {
            manager.magnetometerUpdateInterval = interval
            manager.startMagnetometerUpdates(to: .main) { [weak self] data, _ in
                guard let self, let data else { return }
                let value = Vector3(data.magneticField)
                magneticField = value
                magneticHistory.append(value)
            }
        }

        if manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = interval
            manager.showsDeviceMovementDisplay = true
            let frames = CMMotionManager.availableAttitudeReferenceFrames()
            let frame: CMAttitudeReferenceFrame
            if frames.contains(.xMagneticNorthZVertical) {
                frame = .xMagneticNorthZVertical
                referenceFrame = "Magnetic north"
            } else if frames.contains(.xArbitraryCorrectedZVertical) {
                frame = .xArbitraryCorrectedZVertical
                referenceFrame = "Arbitrary (corrected)"
            } else {
                frame = .xArbitraryZVertical
                referenceFrame = "Arbitrary"
            }
            let northReferenced = frame == .xMagneticNorthZVertical

            manager.startDeviceMotionUpdates(using: frame, to: .main) { [weak self] motion, _ in
                guard let self, let motion else { return }
                let a = motion.attitude
                let att = Vector3(x: a.roll.degrees, y: a.pitch.degrees, z: a.yaw.degrees)
                attitude = att
                attitudeHistory.append(att)
                let q = a.quaternion
                quaternion = Quaternion(x: q.x, y: q.y, z: q.z, w: q.w)
                gravity = Vector3(motion.gravity)
                let user = Vector3(motion.userAcceleration)
                userAcceleration = user
                userAccelerationHistory.append(user)
                unbiasedRotationRate = Vector3(motion.rotationRate)
                calibratedField = Vector3(motion.magneticField.field)
                fieldAccuracy = motion.magneticField.accuracy
                heading = northReferenced && motion.heading >= 0 ? motion.heading : nil
            }
        }
    }

    func stop() {
        manager.stopAccelerometerUpdates()
        manager.stopGyroUpdates()
        manager.stopMagnetometerUpdates()
        manager.stopDeviceMotionUpdates()
    }
}

extension Vector3 {
    init(_ a: CMAcceleration) { self.init(x: a.x, y: a.y, z: a.z) }
    init(_ r: CMRotationRate) { self.init(x: r.x, y: r.y, z: r.z) }
    init(_ m: CMMagneticField) { self.init(x: m.x, y: m.y, z: m.z) }
}

extension CMMagneticFieldCalibrationAccuracy {
    var label: String {
        switch self {
        case .uncalibrated: "Uncalibrated"
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        @unknown default: "Unknown"
        }
    }
}
