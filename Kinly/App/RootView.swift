import SwiftData
import SwiftUI

/// Switches between onboarding and the main constellation experience,
/// and wires up the app's lightweight dependency container.
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("kinly.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var dependencies: AppDependencies?

    var body: some View {
        Group {
            if let dependencies {
                if hasCompletedOnboarding {
                    MainTabView(dependencies: dependencies, onResetOnboarding: { hasCompletedOnboarding = false })
                } else {
                    OnboardingView(dependencies: dependencies, onFinished: { hasCompletedOnboarding = true })
                }
            } else {
                ProgressView()
                    .tint(AppColor.primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColor.background)
            }
        }
        .tint(AppColor.accent)
        .preferredColorScheme(.dark)
        .task {
            let deps = dependencies ?? AppDependencies(modelContext: modelContext)
            if dependencies == nil {
                dependencies = deps
            }
            #if DEBUG
            await DebugSeedData.loadIfNeeded(into: deps)
            #endif
        }
    }
}

#Preview {
    RootView()
        .modelContainer(PreviewSupport.makeContainer())
}
