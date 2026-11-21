import SwiftUI
import Charts

// MARK: - Card

struct SensorCard<Content: View>: View {
    let title: String
    let symbol: String
    var tint: Color = .accentColor
    var status: String?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Label(title, systemImage: symbol)
                    .font(.headline)
                    .foregroundStyle(tint)
                Spacer()
                if let status {
                    Text(status)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
            .padding(.leading, 4)
    }
}

struct UnavailableNote: View {
    var text = "Not available on this device."

    var body: some View {
        Label(text, systemImage: "exclamationmark.triangle")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

// MARK: - Rows

struct ValueRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer(minLength: 12)
            Text(value)
                .monospacedDigit()
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}

struct VectorReadout: View {
    let vector: Vector3
    let unit: String
    var digits = 3
    var labels = ("X", "Y", "Z")
    var showsMagnitude = true

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                axis(labels.0, vector.x, .red)
                axis(labels.1, vector.y, .green)
                axis(labels.2, vector.z, .blue)
                if showsMagnitude {
                    axis("|v|", vector.magnitude, .primary)
                }
            }
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func axis(_ name: String, _ value: Double, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.caption2.weight(.bold))
                .foregroundStyle(color)
            Text(value.fixed(digits, signed: name != "|v|"))
                .font(.system(.callout, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Charts

struct VectorChart: View {
    let series: TimeSeries<Vector3>
    var height: CGFloat = 90

    var body: some View {
        Chart {
            ForEach(series.samples) { sample in
                LineMark(x: .value("t", sample.id), y: .value("X", sample.value.x), series: .value("Axis", "X"))
                    .foregroundStyle(.red)
                LineMark(x: .value("t", sample.id), y: .value("Y", sample.value.y), series: .value("Axis", "Y"))
                    .foregroundStyle(.green)
                LineMark(x: .value("t", sample.id), y: .value("Z", sample.value.z), series: .value("Axis", "Z"))
                    .foregroundStyle(.blue)
            }
            .lineStyle(StrokeStyle(lineWidth: 1.5))
        }
        .chartXScale(domain: series.domain)
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 3))
        }
        .chartLegend(.hidden)
        .frame(height: height)
        .transaction { $0.animation = nil }
    }
}

struct ScalarChart: View {
    let series: TimeSeries<Double>
    var color: Color = .accentColor
    var height: CGFloat = 80

    var body: some View {
        Chart {
            ForEach(series.samples) { sample in
                LineMark(x: .value("t", sample.id), y: .value("v", sample.value))
                    .foregroundStyle(color)
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
            }
        }
        .chartXScale(domain: series.domain)
        .chartYScale(domain: .automatic(includesZero: false))
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 3))
        }
        .frame(height: height)
        .transaction { $0.animation = nil }
    }
}

// MARK: - Gauges

/// Spirit level driven by the gravity vector.
struct LevelBubble: View {
    let gravity: Vector3
    var size: CGFloat = 110

    var body: some View {
        let radius = size / 2
        let bubble: CGFloat = 24
        var dx = CGFloat(-gravity.x) * radius
        var dy = CGFloat(gravity.y) * radius
        let distance = (dx * dx + dy * dy).squareRoot()
        let limit = radius - bubble / 2
        if distance > limit {
            dx *= limit / distance
            dy *= limit / distance
        }
        let isLevel = abs(gravity.x) < 0.02 && abs(gravity.y) < 0.02

        return ZStack {
            Circle().stroke(.secondary.opacity(0.4), lineWidth: 2)
            Circle().stroke(.secondary.opacity(0.4), lineWidth: 1).frame(width: bubble + 8, height: bubble + 8)
            Path { p in
                p.move(to: CGPoint(x: radius, y: 0)); p.addLine(to: CGPoint(x: radius, y: size))
                p.move(to: CGPoint(x: 0, y: radius)); p.addLine(to: CGPoint(x: size, y: radius))
            }
            .stroke(.secondary.opacity(0.2), lineWidth: 1)
            Circle()
                .fill(isLevel ? Color.green : Color.orange)
                .frame(width: bubble, height: bubble)
                .offset(x: dx, y: dy)
        }
        .frame(width: size, height: size)
    }
}

/// Compass card that rotates so the needle at the top always shows the current heading.
struct CompassDial: View {
    let heading: Double
    var size: CGFloat = 130

    var body: some View {
        ZStack {
            ZStack {
                Circle().stroke(.secondary.opacity(0.4), lineWidth: 2)
                ForEach(0..<36) { i in
                    let major = i % 9 == 0
                    Capsule()
                        .fill(major ? Color.primary : Color.secondary)
                        .frame(width: major ? 2.5 : 1, height: major ? 12 : 6)
                        .offset(y: -size / 2 + (major ? 8 : 5))
                        .rotationEffect(.degrees(Double(i) * 10))
                }
                ForEach(Array(["N", "E", "S", "W"].enumerated()), id: \.offset) { index, letter in
                    Text(letter)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(letter == "N" ? Color.red : Color.primary)
                        .offset(y: -size / 2 + 26)
                        .rotationEffect(.degrees(Double(index) * 90))
                }
            }
            .rotationEffect(.degrees(-heading))

            Image(systemName: "arrowtriangle.down.fill")
                .foregroundStyle(.red)
                .offset(y: -size / 2 - 6)
            Text("\(Int(heading.rounded()) % 360)°")
                .font(.title3.monospacedDigit().weight(.semibold))
        }
        .frame(width: size, height: size)
        .padding(.top, 8)
    }
}

struct LevelMeter: View {
    /// 0...1
    let value: Double
    var tint: Color = .accentColor

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color(.tertiarySystemFill))
                Capsule()
                    .fill(tint.gradient)
                    .frame(width: max(6, geo.size.width * min(max(value, 0), 1)))
            }
        }
        .frame(height: 10)
    }
}
