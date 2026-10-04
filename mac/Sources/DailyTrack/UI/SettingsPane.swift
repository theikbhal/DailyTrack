import SwiftUI
import UniformTypeIdentifiers

struct SettingsPane: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var experiments: ExperimentsManager
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var store: DayStore
    @State private var authStatus = "Checking..."
    @State private var showReset = false
    @State private var importURL: URL? = nil
    @State private var importError: String? = nil
    @State private var notice: String? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                profileCard
                experimentsCard
                notificationsCard
                appearanceCard
                if experiments.isEnabled("tursoSync") { syncCard }
                dataCard
                aboutCard
            }
            .padding()
        }
        .navigationTitle("Settings")
        .onAppear { refreshAuth() }
        .fileImporter(isPresented: Binding(get: { importURL != nil }, set: { if !$0 { importURL = nil } }),
                      allowedContentTypes: [.json]) { result in
            if case .success(let url) = result { importFile(url) }
        }
        .alert("Reset everything?", isPresented: $showReset) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                store.resetAll()
                experiments.resetAll()
                notice = "All records, badges and experiment flags cleared."
            }
        } message: {
            Text("This deletes every log, XP, coin and badge on this Mac.")
        }
        .alert("Import", isPresented: Binding(get: { importError != nil }, set: { if $0 { importError = nil } })) {
            Button("OK", role: .cancel) {}
        } message: { Text(importError ?? "") }
    }

    private var profileCard: some View {
        Card(title: "Profile", icon: "person.crop.circle") {
            HStack {
                TextField("Your name (optional)", text: $settings.name)
                    .textFieldStyle(.roundedBorder)
                Pill(text: "single user", color: .teal)
            }
            if let notice {
                Text(notice).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var experimentsCard: some View {
        Card(title: "Experiments - trackers and features", icon: "slider.horizontal.3") {
            VStack(alignment: .leading, spacing: 6) {
                SectionHeader(text: "Trackers")
                ForEach(experiments.trackerExperiments) { exp in
                    experimentRow(exp)
                }
                SectionHeader(text: "Features")
                ForEach(experiments.features) { exp in
                    experimentRow(exp)
                }
                Button("Reset all experiment flags") { experiments.resetAll(); notice = "All trackers and features back to default." }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
        }
    }

    private func experimentRow(_ exp: Experiment) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(exp.name).font(.callout.bold())
                Text(exp.description).font(.caption).foregroundStyle(.secondary).lineLimit(2)
            }
            Spacer()
            Toggle("", isOn: Binding(get: { experiments.isEnabled(exp.id) },
                                     set: { experiments.set(exp.id, $0) }))
                .labelsHidden()
                .toggleStyle(.switch)
        }
        .padding(.vertical, 2)
    }

    private var notificationsCard: some View {
        Card(title: "Daily push notifications", icon: "bell.badge") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Pill(text: authStatus, color: authStatus == "Allowed" ? .green : .orange)
                    Spacer()
                    Button("Send test") { NotificationEngine.shared.sendTest() }
                        .buttonStyle(.bordered).controlSize(.small)
                }
                Toggle("Morning nudge", isOn: $settings.morningOn)
                Stepper("At \(settings.morningHour):00", value: $settings.morningHour, in: 4...11)
                Toggle("Midday nudge", isOn: $settings.middayOn)
                Stepper("At \(settings.middayHour):30", value: $settings.middayHour, in: 11...17)
                Toggle("Evening review", isOn: $settings.eveningOn)
                Stepper("At \(settings.eveningHour):00", value: $settings.eveningHour, in: 17...23)
            }
        }
    }

    private var appearanceCard: some View {
        Card(title: "Appearance - dark mode", icon: "paintbrush") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(AppTheme.allCases) { t in
                    Button {
                        theme.current = t
                        settings.themeRaw = t.rawValue
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: t.symbol).font(.title3)
                            Text(t.label).font(.caption2)
                        }
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(theme.current == t ? t.accent.opacity(0.25) : Color.gray.opacity(0.1),
                                    in: RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(theme.current == t ? t.accent : .clear, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var syncCard: some View {
        Card(title: "Turso sync (experimental)", icon: "icloud") {
            VStack(alignment: .leading, spacing: 8) {
                TextField("DB URL (https://...turso.io)", text: $settings.tursoURL)
                    .textFieldStyle(.roundedBorder)
                SecureField("Token", text: $settings.tursoToken)
                    .textFieldStyle(.roundedBorder)
                Text(settings.syncConfigured
                     ? "Configured. v1 keeps local as the source of truth; sync lands in 1.1."
                     : "Local only. Paste credentials to prepare the sync stub.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var dataCard: some View {
        Card(title: "Data", icon: "externaldrive") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Stored locally: \(store.records.count) day records, \(gameStateText).")
                    .font(.caption).foregroundStyle(.secondary)
                HStack {
                    Button("Export JSON") { exportJSON() }.buttonStyle(.borderedProminent).controlSize(.small)
                    Button("Export CSV") { exportCSV() }.buttonStyle(.bordered).controlSize(.small)
                    Button("Import JSON") {
                        importURL = nil
                        DispatchQueue.main.async { pickImport() }
                    }.buttonStyle(.bordered).controlSize(.small)
                    Spacer()
                    Button("Reset everything", role: .destructive) { showReset = true }
                        .buttonStyle(.bordered).controlSize(.small)
                }
            }
        }
    }

    private var gameStateText: String {
        "\(Game.shared.state.xp) XP, \(Game.shared.state.coins) coins, \(Game.shared.state.badges.count) badges"
    }

    private var aboutCard: some View {
        Card(title: "About", icon: "info.circle") {
            VStack(alignment: .leading, spacing: 6) {
                Text("DailyTrack 1.0.0").font(.headline)
                Text("Single-user daily tracker for zikir, namaz, rest and life. Local first, ADHD friendly, built for one person.")
                    .font(.caption).foregroundStyle(.secondary)
                Text("com.ikbhal.dailytrack").font(.caption2).foregroundStyle(.secondary)
            }
        }
    }

    private func refreshAuth() {
        NotificationEngine.shared.authorizationStatus { text in
            DispatchQueue.main.async { authStatus = text }
        }
    }

    private func pickImport() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            importFile(url)
        }
    }

    private func importFile(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let blob = try JSONDecoder().decode(DayBlob.self, from: data)
            store.importBlob(blob)
            notice = "Imported \(blob.records.count) day records."
        } catch {
            importError = "Could not read that file: \(error.localizedDescription)"
        }
    }

    private func exportJSON() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(store.exportBlob()) else { return }
        save(data, name: "DailyTrack-Export.json")
    }

    private func exportCSV() {
        save(Data(store.exportCSV().utf8), name: "DailyTrack.csv")
    }

    private func save(_ data: Data, name: String) {
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop")
            .appendingPathComponent(name)
        do {
            try data.write(to: url, options: .atomic)
            notice = "Saved \(name) to Desktop."
        } catch {
            importError = error.localizedDescription
        }
    }
}
