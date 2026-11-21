import SwiftUI

struct BarometerCard: View {
    let barometer: BarometerSensor

    var body: some View {
        SensorCard(title: "Barometer", symbol: "barometer", tint: .cyan) {
            if barometer.relativeAvailable {
                HStack(alignment: .firstTextBaseline) {
                    Text(barometer.pressureKPa.map { ($0 * 10).fixed(2) } ?? "—")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                    Text("hPa").foregroundStyle(.secondary)
                }
                ScalarChart(series: barometer.pressureHistory, color: .cyan)
                ValueRow(label: "Pressure", value: barometer.pressureKPa.fixed(4, unit: "kPa"))
                ValueRow(label: "Relative altitude", value: barometer.relativeAltitude.fixed(2, unit: "m", signed: true))
                if barometer.absoluteAvailable {
                    ValueRow(label: "Absolute altitude", value: barometer.absoluteAltitude.fixed(1, unit: "m"))
                    ValueRow(label: "Accuracy", value: barometer.absoluteAccuracy.map { "±\($0.fixed(1)) m" } ?? "—")
                    ValueRow(label: "Precision", value: barometer.absolutePrecision.map { "±\($0.fixed(2)) m" } ?? "—")
                }
                if let error = barometer.error {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
            } else {
                UnavailableNote()
            }
        }
    }
}

struct MicrophoneCard: View {
    let audio: AudioSensor

    var body: some View {
        SensorCard(title: "Microphone", symbol: "waveform", tint: .red,
                   status: audio.isRunning ? "\(Int(audio.sampleRate)) Hz" : "off") {
            if audio.isRunning {
                HStack(alignment: .firstTextBaseline) {
                    Text(audio.rmsDB.fixed(1))
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                    Text("dBFS").foregroundStyle(.secondary)
                }
                LevelMeter(value: (audio.rmsDB + 80) / 80, tint: .red)
                ScalarChart(series: audio.levelHistory, color: .red)
                ValueRow(label: "Peak", value: "\(audio.peakDB.fixed(1)) dBFS")
                ValueRow(label: "Est. loudness (uncalibrated)", value: "≈ \(Int(audio.estimatedSPL)) dB")
            } else {
                Text("Measures the live sound level. Audio is analysed in memory and never recorded.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if let error = audio.error {
                Text(error).font(.caption).foregroundStyle(.red)
            }
            Button(audio.isRunning ? "Stop microphone" : "Start microphone") {
                audio.toggle()
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
    }
}
