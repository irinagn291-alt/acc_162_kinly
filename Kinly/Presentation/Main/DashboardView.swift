import SwiftUI

struct DashboardView: View {
    let dependencies: AppDependencies
    @State private var viewModel: DashboardViewModel

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = State(initialValue: DashboardViewModel(dependencies: dependencies))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView().tint(AppColor.text)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(AppColor.text.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding()
                } else if viewModel.rankings.isEmpty {
                    ContentUnavailableView(
                        "Nothing here yet",
                        systemImage: "chart.bar",
                        description: Text("Add people in your constellation — you'll see who you haven't caught up with in a while.")
                    )
                    .foregroundStyle(AppColor.text)
                } else {
                    List(viewModel.rankings) { ranking in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(ranking.person.name)
                                    .font(.headline)
                                    .foregroundStyle(AppColor.text)
                                Spacer()
                                Text(overdueLabel(ranking.overdueRatio))
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppColor.accent)
                            }

                            Text(viewModel.subtitle(for: ranking))
                                .font(.caption)
                                .foregroundStyle(AppColor.text.opacity(0.6))

                            Text(viewModel.reachOutCopy(for: ranking))
                                .font(.subheadline)
                                .foregroundStyle(AppColor.text.opacity(0.85))

                            Button("Log a connection") {
                                Task { await viewModel.logContact(for: ranking) }
                            }
                            .buttonStyle(KinlyPrimaryButtonStyle())
                        }
                        .padding(.vertical, 6)
                        .listRowBackground(AppColor.surface)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Been a while")
            .task { await viewModel.load() }
        }
        .preferredColorScheme(.dark)
    }

    private func overdueLabel(_ ratio: Double) -> String {
        if ratio.isInfinite { return "not yet" }
        if ratio < 0.8 { return "in rhythm" }
        if ratio < 1.2 { return "almost time" }
        return "a while"
    }
}

#Preview {
    DashboardView(dependencies: PreviewSupport.makeDependencies())
}
