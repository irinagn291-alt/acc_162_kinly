import SwiftUI

struct CircleHubView: View {
    let dependencies: AppDependencies

    private enum Section: String, CaseIterable, Identifiable {
        case reachOut = "Reach-out"
        case timeline = "Timeline"
        case milestones = "Milestones"
        case play = "Play"
        var id: String { rawValue }
    }

    @State private var section: Section = .reachOut

    var body: some View {
        Group {
            switch section {
            case .reachOut: ReachOutKitView(dependencies: dependencies)
            case .timeline: TimelineHubView(dependencies: dependencies)
            case .milestones: MilestonesView(dependencies: dependencies)
            case .play: PlayHubView(dependencies: dependencies)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Picker("Section", selection: $section) {
                ForEach(Section.allCases) { item in
                    Text(item.rawValue).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .background(AppColor.background.opacity(0.96))
        }
        .background(AppColor.background.ignoresSafeArea())
    }
}
