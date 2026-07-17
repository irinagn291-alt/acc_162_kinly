import SwiftUI

struct PlayHubView: View {
    let dependencies: AppDependencies
    @State private var showAlign = false
    @State private var showOrbit = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    card(
                        title: "Constellation Align",
                        subtitle: "Place stars on their silhouettes and earn a starter.",
                        symbol: "sparkles",
                        action: { showAlign = true }
                    )
                    card(
                        title: "Orbit Tap",
                        subtitle: "Catch orbiting lights before they drift away.",
                        symbol: "circle.circle",
                        action: { showOrbit = true }
                    )
                }
                .padding(20)
            }
            .background(AppColor.background.ignoresSafeArea())
            .navigationTitle("Play")
            .sheet(isPresented: $showAlign) {
                ConstellationAlignView(conversationStarterProvider: dependencies.conversationStarterProvider)
            }
            .sheet(isPresented: $showOrbit) {
                OrbitTapView()
            }
        }
    }

    private func card(title: String, subtitle: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.title2)
                    .foregroundStyle(AppColor.primary)
                    .frame(width: 44, height: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline).foregroundStyle(AppColor.text)
                    Text(subtitle).font(.subheadline).foregroundStyle(AppColor.text.opacity(0.65))
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(AppColor.text.opacity(0.35))
            }
            .padding(16)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PlayHubView(dependencies: PreviewSupport.makeDependencies())
}
