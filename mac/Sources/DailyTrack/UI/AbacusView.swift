import SwiftUI

struct BeadShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let cx = r.midX, cy = r.midY
        let sx = r.width * 0.5, sy = r.height * 0.5
        p.move(to: CGPoint(x: cx - sx, y: cy))
        p.addLine(to: CGPoint(x: cx - sx * 0.45, y: cy - sy))
        p.addLine(to: CGPoint(x: cx + sx * 0.45, y: cy - sy))
        p.addLine(to: CGPoint(x: cx + sx, y: cy))
        p.addLine(to: CGPoint(x: cx + sx * 0.45, y: cy + sy))
        p.addLine(to: CGPoint(x: cx - sx * 0.45, y: cy + sy))
        p.closeSubpath()
        return p
    }
}

struct AbacusView: View {
    let count: Int
    let onChange: (Int) -> Void
    var accent: Color = .accentColor
    private let rods = 5
    private let maxCount = 99999

    private func digit(_ i: Int) -> Int {
        let place = Int(pow(10.0, Double(rods - 1 - i)))
        return (count / place) % 10
    }

    private func apply(delta: Int, place: Int) {
        let next = max(0, min(maxCount, count + delta * place))
        onChange(next)
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let spacing = w / CGFloat(rods)
            let beamY = h * 0.40
            let beadW = spacing * 0.66
            let beadH = h * 0.13
            let earthGap = h * 0.145
            let topY = h * 0.14
            let bottomY = h * 0.87

            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient(colors: [accent.opacity(0.35), accent.opacity(0.15)],
                                         startPoint: .top, endPoint: .bottom))
                RoundedRectangle(cornerRadius: 14)
                    .stroke(accent.opacity(0.6), lineWidth: 2)

                ForEach(0..<rods, id: \.self) { i in
                    let x = spacing * (CGFloat(i) + 0.5)
                    Capsule()
                        .fill(Color.primary.opacity(0.35))
                        .frame(width: 3)
                        .position(x: x, y: h / 2)
                    Text("\(Int(pow(10.0, Double(rods - 1 - i))))")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                        .position(x: x, y: h - 6)
                }

                Rectangle()
                    .fill(accent.opacity(0.85))
                    .frame(height: 6)
                    .position(x: w / 2, y: beamY)

                ForEach(0..<rods, id: \.self) { i in
                    let x = spacing * (CGFloat(i) + 0.5)
                    let d = digit(i)
                    let place = Int(pow(10.0, Double(rods - 1 - i)))
                    let earth = d % 5

                    BeadShape()
                        .fill(d >= 5 ? AnyShapeStyle(accent.gradient) : AnyShapeStyle(.gray.opacity(0.45)))
                        .overlay(Capsule().fill(.white.opacity(0.35)).frame(width: 3, height: beadH * 0.3).offset(x: -beadW * 0.18))
                        .frame(width: beadW, height: beadH)
                        .shadow(color: .black.opacity(0.25), radius: 2, y: 2)
                        .position(x: x, y: d >= 5 ? beamY - 16 : topY)
                        .animation(.spring(duration: 0.25), value: d)
                        .onTapGesture {
                            apply(delta: d >= 5 ? -5 : 5, place: place)
                        }

                    ForEach(0..<4, id: \.self) { j in
                        let active = j < earth
                        let y: CGFloat = active
                            ? beamY + 16 + CGFloat(j) * earthGap
                            : bottomY - CGFloat(3 - j) * earthGap
                        BeadShape()
                            .fill(active ? AnyShapeStyle(accent.gradient) : AnyShapeStyle(.gray.opacity(0.45)))
                            .overlay(Capsule().fill(.white.opacity(0.35)).frame(width: 3, height: beadH * 0.3).offset(x: -beadW * 0.18))
                            .frame(width: beadW, height: beadH)
                            .shadow(color: .black.opacity(0.25), radius: 2, y: 2)
                            .position(x: x, y: y)
                            .animation(.spring(duration: 0.25), value: earth)
                            .onTapGesture {
                                apply(delta: j < earth ? j - earth : j + 1 - earth, place: place)
                            }
                    }
                }
            }
        }
        .frame(height: 168)
    }
}

struct AbacusCounterCard: View {
    let tracker: Tracker
    let value: Int
    let onChange: (Int) -> Void
    let experiments: ExperimentsManager
    @EnvironmentObject private var theme: ThemeManager

    var body: some View {
        Card(title: tracker.title, icon: tracker.icon) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(value)")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        Text("/ \(tracker.target)")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    Text(tracker.detail).font(.caption).foregroundStyle(.secondary)
                    Bar(progress: Double(value) / Double(tracker.target), color: theme.current.accent)
                    HStack(spacing: 8) {
                        ForEach([1, 10, 100], id: \.self) { step in
                            Button("+\(step)") { onChange(value + step) }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                        }
                        Button("-1") { onChange(max(0, value - 1)) }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        Button("Reset") { onChange(0) }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                    }
                }
                if experiments.isEnabled("abacus") {
                    AbacusView(count: value, onChange: onChange, accent: theme.current.accent)
                        .frame(width: 250)
                }
            }
        }
    }
}
