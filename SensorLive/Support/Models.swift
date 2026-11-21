import Foundation

/// A simple 3-axis value used by most motion sensors.
struct Vector3: Equatable {
    var x: Double
    var y: Double
    var z: Double

    static let zero = Vector3(x: 0, y: 0, z: 0)

    var magnitude: Double { (x * x + y * y + z * z).squareRoot() }
}

struct Quaternion: Equatable {
    var x: Double
    var y: Double
    var z: Double
    var w: Double

    static let identity = Quaternion(x: 0, y: 0, z: 0, w: 1)
}

/// Fixed-size rolling history used to draw live charts.
struct TimeSeries<Value> {
    struct Sample: Identifiable {
        let id: Int
        let value: Value
    }

    let capacity: Int
    private(set) var samples: [Sample] = []
    private var counter = 0

    init(capacity: Int = 150) {
        self.capacity = capacity
    }

    mutating func append(_ value: Value) {
        counter += 1
        samples.append(Sample(id: counter, value: value))
        if samples.count > capacity {
            samples.removeFirst(samples.count - capacity)
        }
    }

    mutating func removeAll() {
        samples.removeAll()
    }

    /// A sliding window so the chart scrolls at a constant speed.
    var domain: ClosedRange<Int> {
        let last = max(counter, 1)
        return (last - capacity + 1)...last
    }
}

extension Double {
    var degrees: Double { self * 180 / .pi }

    func fixed(_ digits: Int, signed: Bool = false) -> String {
        String(format: signed ? "%+.\(digits)f" : "%.\(digits)f", self)
    }
}

extension Optional where Wrapped == Double {
    func fixed(_ digits: Int, unit: String = "", signed: Bool = false) -> String {
        guard let value = self else { return "—" }
        let text = value.fixed(digits, signed: signed)
        return unit.isEmpty ? text : "\(text) \(unit)"
    }
}
