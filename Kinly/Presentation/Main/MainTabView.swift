import SwiftUI

struct MainTabView: View {
    let dependencies: AppDependencies
    let onResetOnboarding: () -> Void

    private enum Tab: Hashable {
        case constellation, circle, dashboard, settings
    }

    @State private var tab: Tab = .constellation

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch tab {
                case .constellation:
                    ConstellationView(dependencies: dependencies)
                case .circle:
                    CircleHubView(dependencies: dependencies)
                case .dashboard:
                    DashboardView(dependencies: dependencies)
                case .settings:
                    SettingsView(dependencies: dependencies, onResetOnboarding: onResetOnboarding)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            HStack(spacing: 0) {
                tabButton(.constellation, title: "Stars", systemImage: "sparkles")
                tabButton(.circle, title: "Circle", systemImage: "person.3.fill")
                tabButton(.dashboard, title: "While", systemImage: "chart.bar.fill")
                tabButton(.settings, title: "Settings", systemImage: "gearshape.fill")
            }
            .padding(.top, 8)
            .padding(.bottom, 6)
            .background(AppColor.background.ignoresSafeArea(edges: .bottom))
        }
        .tint(AppColor.accent)
        .background(AppColor.background.ignoresSafeArea())
    }

    private func tabButton(_ value: Tab, title: String, systemImage: String) -> some View {
        Button { tab = value } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption2.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(tab == value ? AppColor.accent : AppColor.text.opacity(0.45))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView(dependencies: PreviewSupport.makeDependencies(), onResetOnboarding: {})
}
