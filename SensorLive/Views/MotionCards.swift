import SwiftUI

struct AccelerometerCard: View {
    let motion: MotionSensors

    var body: some View {
        SensorCard(title: "Accelerometer", symbol: "move.3d", tint: .orange, status: "raw") {
            if motion.accelerometerAvailable {
                VectorReadout(vector: motion.acceleration, unit: "g (1 g = 9.81 m/s²)")
                VectorChart(series: motion.accelerationHistory)
            } else {
                UnavailableNote()
            }
        }
    }
}

struct GyroscopeCard: View {
    let motion: MotionSensors

    var body: some View {
        SensorCard(title: "Gyroscope", symbol: "gyroscope", tint: .purple, status: "raw") {
            if motion.gyroAvailable {
                VectorReadout(vector: motion.rotationRate, unit: "rad/s")
                VectorChart(series: motion.rotationHistory)
            } else {
                UnavailableNote()
            }
        }
    }
}

struct MagnetometerCard: View {
    let motion: MotionSensors

    var body: some View {
        SensorCard(title: "Magnetometer", symbol: "dot.radiowaves.left.and.right", tint: .teal, status: "raw") {
            if motion.magnetometerAvailable {
                VectorReadout(vector: motion.magneticField, unit: "µT (uncalibrated, includes device bias)", digits: 1)
                VectorChart(series: motion.magneticHistory)
            } else {
                UnavailableNote()
            }
        }
    }
}

struct AttitudeCard: View {
    let motion: MotionSensors

    var body: some View {
        SensorCard(title: "Attitude", symbol: "rotate.3d", tint: .indigo, status: motion.referenceFrame) {
            if motion.deviceMotionAvailable {
                HStack(alignment: .center, spacing: 16) {
                    LevelBubble(gravity: motion.gravity)
                    VStack(spacing: 6) {
                        ValueRow(label: "Roll", value: "\(motion.attitude.x.fixed(1, signed: true))°")
                        ValueRow(label: "Pitch", value: "\(motion.attitude.y.fixed(1, signed: true))°")
                        ValueRow(label: "Yaw", value: "\(motion.attitude.z.fixed(1, signed: true))°")
                        ValueRow(label: "Heading", value: motion.heading.fixed(1, unit: "°"))
                    }
                }
                VectorChart(series: motion.attitudeHistory, height: 70)
                let q = motion.quaternion
                ValueRow(label: "Quaternion",
                         value: "x \(q.x.fixed(3)) y \(q.y.fixed(3)) z \(q.z.fixed(3)) w \(q.w.fixed(3))")
                    .font(.caption)
            } else {
                UnavailableNote()
            }
        }
    }
}

struct DeviceMotionCard: View {
    let motion: MotionSensors

    var body: some View {
        SensorCard(title: "Device Motion", symbol: "figure.walk.motion", tint: .pink, status: "sensor fusion") {
            if motion.deviceMotionAvailable {
                Text("User acceleration (gravity removed)").font(.caption).foregroundStyle(.secondary)
                VectorReadout(vector: motion.userAcceleration, unit: "g")
                VectorChart(series: motion.userAccelerationHistory, height: 70)
                Divider()
                Group {
                    Text("Gravity").font(.caption).foregroundStyle(.secondary)
                    VectorReadout(vector: motion.gravity, unit: "g")
                    Divider()
                    Text("Rotation rate (bias removed)").font(.caption).foregroundStyle(.secondary)
                    VectorReadout(vector: motion.unbiasedRotationRate, unit: "rad/s")
                    Divider()
                    Text("Calibrated magnetic field").font(.caption).foregroundStyle(.secondary)
                    VectorReadout(vector: motion.calibratedField, unit: "µT · accuracy: \(motion.fieldAccuracy.label)", digits: 1)
                }
            } else {
                UnavailableNote()
            }
        }
    }
}
