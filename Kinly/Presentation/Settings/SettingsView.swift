import SwiftUI

struct SettingsView: View {
    let dependencies: AppDependencies
    let onResetOnboarding: () -> Void

    @State private var remindersEnabled = false
    @State private var showContactsImport = false
    @State private var showResetConfirmation = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Reminders") {
                    Toggle("Gentle reminders", isOn: $remindersEnabled)
                        .onChange(of: remindersEnabled) { _, enabled in
                            Task { await updateReminders(enabled) }
                        }
                    Text("Local notifications with no guilt — just a soft nudge to reconnect.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("People") {
                    Button("Import from Contacts") { showContactsImport = true }
                }

                Section("About") {
                    Text("Kinly")
                        .font(.headline)
                    Text("A constellation of the people you care about — gentle reminders to stay in touch.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Link("Contact Us", destination: URL(string: "https://kinly-lyly.pro/contact-us")!)
                    Link("Privacy Policy", destination: URL(string: "https://kinly-lyly.pro/privacy-policy")!)
                }

                #if DEBUG
                Section("Demo data") {
                    Button("Load demo constellation") {
                        Task { await loadDemoSeed() }
                    }
                    Button("Reset demo data", role: .destructive) {
                        Task { await resetDemoSeed() }
                    }
                    Text("DEBUG + Simulator only. Seeds five people with mixed rhythms and contact history.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                #endif

                Section {
                    Button("Reset data and onboarding", role: .destructive) {
                        showResetConfirmation = true
                    }
                }
            }
            .navigationTitle("Settings")
            .scrollContentBackground(.hidden)
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
            .background(AppColor.background)
            .task {
                remindersEnabled = await dependencies.reminderScheduler.currentAuthorizationStatus()
            }
            .sheet(isPresented: $showContactsImport) {
                ImportContactsSheet(dependencies: dependencies) { contacts in
                    Task { await importContacts(contacts) }
                }
            }
            .alert("Reset everything?", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    Task { await resetAll() }
                }
            } message: {
                Text("People, contact history, and reminders will be removed.")
            }
            .alert("Something went wrong", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
        .preferredColorScheme(.dark)
    }

    private func updateReminders(_ enabled: Bool) async {
        if enabled {
            let granted = await dependencies.reminderScheduler.requestAuthorization()
            remindersEnabled = granted
            if granted {
                let people = (try? await dependencies.personRepository.fetchAll()) ?? []
                for person in people {
                    await dependencies.reminderScheduler.scheduleGentleReminder(for: person)
                }
            }
        } else {
            await dependencies.reminderScheduler.cancelAll()
        }
    }

    private func importContacts(_ contacts: [ImportableContact]) async {
        do {
            for contact in contacts {
                let person = Person(name: contact.name)
                try await dependencies.personRepository.add(person)
                if remindersEnabled {
                    await dependencies.reminderScheduler.scheduleGentleReminder(for: person)
                }
            }
        } catch {
            errorMessage = "Couldn't import contacts."
        }
    }

    private func resetAll() async {
        do {
            try await dependencies.personRepository.deleteAll()
            try await dependencies.interactionRepository.deleteAll()
            await dependencies.reminderScheduler.cancelAll()
            onResetOnboarding()
        } catch {
            errorMessage = "Couldn't reset data."
        }
    }

    #if DEBUG
    private func loadDemoSeed() async {
        guard DebugSeedData.isSimulator else {
            errorMessage = "Demo seed is available on Simulator only."
            return
        }
        do {
            try await DebugSeedData.reset(into: dependencies)
            try await DebugSeedData.seed(into: dependencies)
        } catch {
            errorMessage = "Couldn't load demo data."
        }
    }

    private func resetDemoSeed() async {
        do {
            try await DebugSeedData.reset(into: dependencies)
        } catch {
            errorMessage = "Couldn't reset demo data."
        }
    }
    #endif
}

#Preview {
    SettingsView(dependencies: PreviewSupport.makeDependencies(), onResetOnboarding: {})
}
