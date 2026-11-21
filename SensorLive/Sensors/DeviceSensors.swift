import UIKit
import Observation

/// Proximity sensor, battery, thermal state, power mode, screen brightness and orientation.
@Observable
final class DeviceSensors {
    var batteryLevel: Float = -1
    var batteryState: UIDevice.BatteryState = .unknown
    var thermalState: ProcessInfo.ThermalState = .nominal
    var lowPowerMode = false
    var brightness: Double = 0
    var orientation: UIDeviceOrientation = .unknown

    var proximityEnabled = false
    var proximityAvailable = true
    var proximityNear = false

    var model = ""
    var systemVersion = ""

    @ObservationIgnored private var observers: [NSObjectProtocol] = []
    @ObservationIgnored private var brightnessTimer: Timer?

    func start() {
        guard observers.isEmpty else { return }
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        device.beginGeneratingDeviceOrientationNotifications()
        model = device.model
        systemVersion = "\(device.systemName) \(device.systemVersion)"

        let center = NotificationCenter.default
        let names: [Notification.Name] = [
            UIDevice.batteryLevelDidChangeNotification,
            UIDevice.batteryStateDidChangeNotification,
            UIDevice.orientationDidChangeNotification,
            UIDevice.proximityStateDidChangeNotification,
            ProcessInfo.thermalStateDidChangeNotification,
            .NSProcessInfoPowerStateDidChange,
            UIScreen.brightnessDidChangeNotification,
        ]
        observers = names.map { name in
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                self?.refresh()
            }
        }

        // Brightness notifications can be sparse with auto-brightness, so poll gently too.
        brightnessTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.refreshBrightness()
        }
        refresh()
    }

    func stop() {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers.removeAll()
        brightnessTimer?.invalidate()
        brightnessTimer = nil
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        setProximity(false)
    }

    func setProximity(_ enabled: Bool) {
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = enabled
        if enabled && !device.isProximityMonitoringEnabled {
            proximityAvailable = false
        }
        proximityEnabled = device.isProximityMonitoringEnabled
        proximityNear = device.proximityState
    }

    private func refresh() {
        let device = UIDevice.current
        batteryLevel = device.batteryLevel
        batteryState = device.batteryState
        orientation = device.orientation
        proximityNear = device.proximityState
        thermalState = ProcessInfo.processInfo.thermalState
        lowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
        refreshBrightness()
    }

    private func refreshBrightness() {
        let screen = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen
        if let screen {
            brightness = Double(screen.brightness)
        }
    }
}

extension UIDevice.BatteryState {
    var label: String {
        switch self {
        case .unknown: "Unknown"
        case .unplugged: "On battery"
        case .charging: "Charging"
        case .full: "Full"
        @unknown default: "Unknown"
        }
    }
}

extension ProcessInfo.ThermalState {
    var label: String {
        switch self {
        case .nominal: "Nominal"
        case .fair: "Fair"
        case .serious: "Serious"
        case .critical: "Critical"
        @unknown default: "Unknown"
        }
    }
}

extension UIDeviceOrientation {
    var label: String {
        switch self {
        case .portrait: "Portrait"
        case .portraitUpsideDown: "Upside down"
        case .landscapeLeft: "Landscape left"
        case .landscapeRight: "Landscape right"
        case .faceUp: "Face up"
        case .faceDown: "Face down"
        case .unknown: "Unknown"
        @unknown default: "Unknown"
        }
    }
}
