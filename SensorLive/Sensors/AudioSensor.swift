import AVFoundation
import Observation

/// Live microphone level (RMS and peak, in dBFS) via an AVAudioEngine input tap.
/// Audio is analysed in memory only; nothing is recorded or saved.
@Observable
final class AudioSensor {
    var isRunning = false
    var rmsDB: Double = -160
    var peakDB: Double = -160
    var levelHistory = TimeSeries<Double>()
    var sampleRate: Double = 0
    var error: String?

    @ObservationIgnored private let engine = AVAudioEngine()

    /// Rough, uncalibrated sound-pressure estimate. iPhone mics clip around ~120 dB SPL.
    var estimatedSPL: Double { max(0, rmsDB + 110) }

    func toggle() {
        isRunning ? stop() : start()
    }

    func start() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                guard let self else { return }
                if granted {
                    self.begin()
                } else {
                    self.error = "Microphone access denied. Enable it in Settings › Privacy › Microphone."
                }
            }
        }
    }

    func stop() {
        guard isRunning else { return }
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        isRunning = false
        rmsDB = -160
        peakDB = -160
    }

    private func begin() {
        guard !isRunning else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement)
            try session.setActive(true)

            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)
            sampleRate = format.sampleRate

            input.installTap(onBus: 0, bufferSize: 2048, format: format) { [weak self] buffer, _ in
                guard let channel = buffer.floatChannelData?[0] else { return }
                let count = Int(buffer.frameLength)
                guard count > 0 else { return }
                var sum: Float = 0
                var peak: Float = 0
                for i in 0..<count {
                    let s = channel[i]
                    sum += s * s
                    peak = max(peak, abs(s))
                }
                let rms = (sum / Float(count)).squareRoot()
                let rmsDB = Double(20 * log10(max(rms, 1e-8)))
                let peakDB = Double(20 * log10(max(peak, 1e-8)))
                DispatchQueue.main.async {
                    guard let self, self.isRunning else { return }
                    self.rmsDB = rmsDB
                    self.peakDB = peakDB
                    self.levelHistory.append(max(rmsDB, -100))
                }
            }

            engine.prepare()
            try engine.start()
            error = nil
            isRunning = true
        } catch {
            self.error = error.localizedDescription
            engine.inputNode.removeTap(onBus: 0)
        }
    }
}
