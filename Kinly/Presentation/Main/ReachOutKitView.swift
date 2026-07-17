import SwiftUI

struct ReachOutKitView: View {
    let dependencies: AppDependencies
    @State private var people: [Person] = []
    @State private var selectedPerson: Person?
    @State private var starters: [String] = []
    @State private var message = ""

    var body: some View {
        NavigationStack {
            Group {
                if people.isEmpty {
                    ContentUnavailableView(
                        "Add someone first",
                        systemImage: "person.crop.circle.badge.plus",
                        description: Text("Reach-out kit needs at least one person in your constellation.")
                    )
                    .foregroundStyle(AppColor.text)
                } else {
                    List {
                        Section("Who") {
                            Picker("Person", selection: $selectedPerson) {
                                ForEach(people) { person in
                                    Text(person.name).tag(Optional(person))
                                }
                            }
                            .onChange(of: selectedPerson) { _, _ in refreshCopy() }
                        }
                        if let selectedPerson {
                            Section("Message") {
                                Text(message)
                                    .foregroundStyle(AppColor.text)
                                ShareLink(item: message) {
                                    Label("Share message", systemImage: "square.and.arrow.up")
                                }
                            }
                            Section("Conversation starters") {
                                ForEach(starters, id: \.self) { starter in
                                    Text(starter)
                                        .font(.subheadline)
                                        .foregroundStyle(AppColor.text.opacity(0.9))
                                        .padding(.vertical, 2)
                                }
                            }
                            Section {
                                Button("Shuffle starters") {
                                    starters = dependencies.conversationStarterProvider.suggestions(count: 6)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppColor.background.ignoresSafeArea())
            .navigationTitle("Reach-out")
            .task {
                people = (try? await dependencies.personRepository.fetchAll()) ?? []
                selectedPerson = people.first
                refreshCopy()
            }
        }
    }

    private func refreshCopy() {
        guard let selectedPerson else { return }
        message = ReachOutMessageBuilder.body(
            personName: selectedPerson.name,
            rhythmDays: selectedPerson.contactRhythmDays
        )
        starters = dependencies.conversationStarterProvider.suggestions(count: 6)
    }
}
