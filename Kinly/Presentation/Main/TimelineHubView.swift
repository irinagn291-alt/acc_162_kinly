import SwiftUI

struct TimelineHubView: View {
    let dependencies: AppDependencies
    @State private var people: [Person] = []
    @State private var selectedID: UUID?
    @State private var interactions: [Interaction] = []

    var body: some View {
        NavigationStack {
            Group {
                if people.isEmpty {
                    ContentUnavailableView(
                        "No timeline yet",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Log a few check-ins — history with each person appears here.")
                    )
                    .foregroundStyle(AppColor.text)
                } else {
                    List {
                        Section("Person") {
                            Picker("Person", selection: $selectedID) {
                                ForEach(people) { person in
                                    Text(person.name).tag(Optional(person.id))
                                }
                            }
                            .onChange(of: selectedID) { _, _ in
                                Task { await loadTimeline() }
                            }
                        }
                        Section("History") {
                            if interactions.isEmpty {
                                Text("No touches logged yet.")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(interactions) { item in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(AppColor.primary)
                                        if let note = item.note, !note.isEmpty {
                                            Text(note)
                                                .font(.subheadline)
                                                .foregroundStyle(AppColor.text.opacity(0.85))
                                        }
                                        if item.isImportantDate {
                                            Label("Important", systemImage: "star.fill")
                                                .font(.caption)
                                                .foregroundStyle(AppColor.accent)
                                        }
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppColor.background.ignoresSafeArea())
            .navigationTitle("Timeline")
            .task {
                people = (try? await dependencies.personRepository.fetchAll()) ?? []
                selectedID = people.first?.id
                await loadTimeline()
            }
        }
    }

    private func loadTimeline() async {
        guard let selectedID else {
            interactions = []
            return
        }
        interactions = (try? await dependencies.interactionRepository.fetchAll(forPersonID: selectedID)) ?? []
    }
}
