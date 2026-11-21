import SwiftUI

struct ContentView: View {
    @Environment(SensorHub.self) private var hub
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("keepAwake") private var keepAwake = true
    @State private var paused = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    SectionHeader(title: "Motion")
                    AccelerometerCard(motion: hub.motion)
                    GyroscopeCard(motion: hub.motion)
                    MagnetometerCard(motion: hub.motion)
                    AttitudeCard(motion: hub.motion)
                    DeviceMotionCard(motion: hub.motion)

                    SectionHeader(title: "Environment")
                    BarometerCard(barometer: hub.barometer)
                    MicrophoneCard(audio: hub.audio)

                    SectionHeader(title: "Location")
                    GPSCard(location: hub.location)
                    CompassCard(location: hub.location)

                    SectionHeader(title: "Activity")
                    PedometerCard(activity: hub.activity)
                    MotionActivityCard(activity: hub.activity)

                    SectionHeader(title: "Device")
                    ProximityCard(device: hub.device)
                    BatteryCard(device: hub.device)
                    DisplayCard(device: hub.device)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Sensors Live")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        paused.toggle()
                        paused ? hub.stopAll() : hub.startAll()
                    } label: {
                        Image(systemName: paused ? "play.fill" : "pause.fill")
                    }
                    .accessibilityLabel(paused ? "Resume sensors" : "Pause sensors")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    settingsMenu
                }
            }
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            switch phase {
            case .active:
                if !paused { hub.startAll() }
                UIApplication.shared.isIdleTimerDisabled = keepAwake
            case .background:
                hub.stopAll()
            default:
                break
            }
        }
        .onChange(of: keepAwake) { _, value in
            UIApplication.shared.isIdleTimerDisabled = value
        }
    }

    private var settingsMenu: some View {
        Menu {
            Picker("Motion sample rate", selection: Binding(
                get: { hub.sampleRate },
                set: { hub.setSampleRate($0) }
            )) {
                ForEach(SensorHub.sampleRates, id: \.self) { rate in
                    Text("\(Int(rate)) Hz").tag(rate)
                }
            }
            .pickerStyle(.menu)
            Toggle("Keep screen awake", isOn: $keepAwake)
        } label: {
            Image(systemName: "slider.horizontal.3")
        }
        .accessibilityLabel("Settings")
    }
}
