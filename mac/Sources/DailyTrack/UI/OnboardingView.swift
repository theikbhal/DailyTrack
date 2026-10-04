import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var theme: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var page = 0
    @State private var name = ""

    private let slides: [(icon: String, title: String, body: String)] = [
        ("target", "Your minimum, not your fantasy",
         "DailyTrack shows only the trackers you enable. Darood 1100, astaghfar 1100, namaz, sleep and two life calls - everything else stays hidden."),
        ("fingerprint", "Count with the abacus",
         "Zikir counters get a bead board. Tap a bead to set the digit, or use +1, +10, +100. The count is saved the moment you touch it."),
        ("flame", "Streaks, levels and badges",
         "A day is kept at 75 percent average. Kept days build your streak, XP moves you through eight levels, and sixteen badges mark the big wins."),
        ("bell.badge", "Daily nudges you can turn off",
         "Morning, midday and evening push notifications by default. Every tracker is a switch in Settings > Experiments - you are in charge.")
    ]

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button("Skip") { finish() }.buttonStyle(.plain).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: slides[page].icon)
                .font(.system(size: 64))
                .foregroundStyle(theme.current.gradient)
                .symbolEffect(.pulse, options: .repeating)
            Text(slides[page].title).font(.title.bold()).multilineTextAlignment(.center)
            Text(slides[page].body)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 440)
            if page == 1 {
                TextField("What should the app call you?", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 300)
            }
            HStack {
                ForEach(0..<slides.count, id: \.self) { i in
                    Circle().fill(i == page ? theme.current.accent : Color.gray.opacity(0.4))
                        .frame(width: 8, height: 8)
                }
            }
            HStack {
                Button("Back") { if page > 0 { page -= 1 } }
                    .buttonStyle(.bordered)
                    .disabled(page == 0)
                Spacer()
                Button(page == slides.count - 1 ? "Start my day" : "Next") {
                    if page == slides.count - 1 { finish() } else { page += 1 }
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: 340)
            Spacer()
        }
        .padding(40)
        .frame(width: 560, height: 440)
    }

    private func finish() {
        if !name.trimmingCharacters(in: .whitespaces).isEmpty {
            settings.name = name.trimmingCharacters(in: .whitespaces)
        }
        settings.onboardingDone = true
        dismiss()
    }
}
