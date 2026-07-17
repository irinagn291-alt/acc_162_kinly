import SwiftUI

struct MilestonesView: View {
    let dependencies: AppDependencies
    @State private var rankings: [OverdueRanking] = []

    var body: some View {
        NavigationStack {
            Group {
                if rankings.isEmpty {
                    ContentUnavailableView(
                        "No milestones yet",
                        systemImage: "flag",
                        description: Text("Add people and log touches — soft milestones will show up here.")
                    )
                    .foregroundStyle(AppColor.text)
                } else {
                    List {
                        Section("Soft reminders") {
                            ForEach(rankings) { item in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(item.person.name)
                                        .font(.headline)
                                        .foregroundStyle(AppColor.text)
                                    Text(statusLine(for: item))
                                        .font(.subheadline)
                                        .foregroundStyle(AppColor.text.opacity(0.7))
                                    Text("Rhythm: every \(item.person.contactRhythmDays) days")
                                        .font(.caption)
                                        .foregroundStyle(AppColor.primary.opacity(0.8))
                                }
                                .padding(.vertical, 4)
                                .listRowBackground(AppColor.surface.opacity(0.65))
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppColor.background.ignoresSafeArea())
            .navigationTitle("Milestones")
            .task {
                rankings = (try? await dependencies.overdueRankingUseCase.execute()) ?? []
            }
        }
    }

    private func statusLine(for item: OverdueRanking) -> String {
        if let last = item.lastInteractionDate {
            let days = Calendar.current.dateComponents([.day], from: last, to: .now).day ?? 0
            if item.overdueRatio >= 1 {
                return "Been \(days) days — a gentle nudge might feel nice."
            }
            return "Last touch \(days) days ago — still within your rhythm."
        }
        return "No touches yet — a first hello could start the constellation."
    }
}
