import SwiftUI

struct MainTabView: View {
    let dependencies: AppDependencies
    let onResetOnboarding: () -> Void

    var body: some View {
        TabView {
            ConstellationView(dependencies: dependencies)
                .tabItem { Label("Constellation", systemImage: "sparkles") }

            CircleHubView(dependencies: dependencies)
                .tabItem { Label("Circle", systemImage: "person.3.fill") }

            DashboardView(dependencies: dependencies)
                .tabItem { Label("Been a while", systemImage: "chart.bar.fill") }

            SettingsView(dependencies: dependencies, onResetOnboarding: onResetOnboarding)
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(AppColor.accent)
    }
}

#Preview {
    MainTabView(dependencies: PreviewSupport.makeDependencies(), onResetOnboarding: {})
}
