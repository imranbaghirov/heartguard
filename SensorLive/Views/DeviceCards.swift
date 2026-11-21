import SwiftUI

struct ProximityCard: View {
    let device: DeviceSensors

    var body: some View {
        SensorCard(title: "Proximity", symbol: "sensor.fill", tint: .yellow) {
            if device.proximityAvailable {
                Toggle("Monitor proximity", isOn: Binding(
                    get: { device.proximityEnabled },
                    set: { device.setProximity($0) }
                ))
                .font(.subheadline)
                if device.proximityEnabled {
                    HStack {
                        Circle()
                            .fill(device.proximityNear ? Color.yellow : Color.secondary.opacity(0.3))
                            .frame(width: 14, height: 14)
                        Text(device.proximityNear ? "Object near" : "Nothing near")
                            .font(.title3.weight(.semibold))
                    }
                    Text("The screen turns off while something covers the sensor; that's iOS behaviour.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                UnavailableNote()
            }
        }
    }
}

struct BatteryCard: View {
    let device: DeviceSensors

    var body: some View {
        SensorCard(title: "Battery & Power", symbol: batterySymbol, tint: .green) {
            if device.batteryLevel >= 0 {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(Int((device.batteryLevel * 100).rounded()))")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                    Text("%").foregroundStyle(.secondary)
                }
                LevelMeter(value: Double(device.batteryLevel), tint: device.batteryLevel < 0.2 ? .red : .green)
            }
            ValueRow(label: "State", value: device.batteryState.label)
            ValueRow(label: "Low Power Mode", value: device.lowPowerMode ? "On" : "Off")
            ValueRow(label: "Thermal state", value: device.thermalState.label)
        }
    }

    private var batterySymbol: String {
        if device.batteryState == .charging { return "battery.100.bolt" }
        switch device.batteryLevel {
        case ..<0: return "battery.0"
        case ..<0.25: return "battery.25"
        case ..<0.5: return "battery.50"
        case ..<0.75: return "battery.75"
        default: return "battery.100"
        }
    }
}

struct DisplayCard: View {
    let device: DeviceSensors

    var body: some View {
        SensorCard(title: "Display & Orientation", symbol: "iphone", tint: .gray) {
            ValueRow(label: "Screen brightness", value: "\(Int((device.brightness * 100).rounded())) %")
            LevelMeter(value: device.brightness, tint: .yellow)
            Text("Follows the ambient light sensor when Auto-Brightness is on.")
                .font(.caption)
                .foregroundStyle(.secondary)
            ValueRow(label: "Orientation", value: device.orientation.label)
            ValueRow(label: "Model", value: device.model)
            ValueRow(label: "System", value: device.systemVersion)
        }
    }
}
