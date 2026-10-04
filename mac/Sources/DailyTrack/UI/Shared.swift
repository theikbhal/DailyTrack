import SwiftUI

struct Card<Content: View>: View {
    let title: String
    var icon: String = "square.grid.2x2"
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(.secondary)
            content
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    var color: Color = .accentColor

    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.title2.bold()).foregroundStyle(color)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct ProgressRing: View {
    let progress: Double
    var color: Color = .accentColor
    var lineWidth: CGFloat = 10

    var body: some View {
        ZStack {
            Circle().stroke(color.opacity(0.18), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.001, min(1, progress)))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.4), value: progress)
        }
    }
}

struct Pill: View {
    let text: String
    var color: Color = .accentColor

    var body: some View {
        Text(text)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.18), in: Capsule())
            .foregroundStyle(color)
    }
}

struct Bar: View {
    let progress: Double
    var color: Color = .accentColor
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(color.opacity(0.15))
                Capsule().fill(color)
                    .frame(width: geo.size.width * max(0, min(1, progress)))
            }
        }
        .frame(height: height)
    }
}

struct ConfettiBurst: View {
    let trigger: Int
    @State private var on = false
    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

    var body: some View {
        ZStack {
            if on {
                ForEach(0..<24, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colors[i % colors.count])
                        .frame(width: 8, height: 12)
                        .rotationEffect(.degrees(Double(i) * 15))
                        .offset(y: on ? 260 : 0)
                        .opacity(on ? 0 : 1)
                        .animation(.easeOut(duration: 1.4).delay(Double(i) * 0.03), value: on)
                }
            }
        }
        .allowsHitTesting(false)
        .onChange(of: trigger) { _, new in
            guard new > 0 else { return }
            on = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) { on = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { on = false }
        }
    }
}

struct SectionHeader: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(.caption.bold())
            .foregroundStyle(.secondary)
            .padding(.top, 6)
    }
}
