import SwiftUI

struct OrbitTapView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var orbs: [Orb] = []
    @State private var caught = 0
    @State private var isComplete = false
    private let target = 10

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(isComplete ? "Orbit calm" : "Tap the orbiting lights")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppColor.text)
                Text("\(caught)/\(target)")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.text.opacity(0.65))

                ZStack {
                    ForEach(orbs) { orb in
                        Circle()
                            .fill(AppColor.primary.opacity(orb.opacity))
                            .frame(width: orb.size, height: orb.size)
                            .position(orb.position)
                            .onTapGesture { catchOrb(orb) }
                    }
                }
                .frame(height: 360)
                .background(AppColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 20)

                if isComplete {
                    Button("Again") { reset() }
                        .buttonStyle(.borderedProminent)
                        .tint(AppColor.primary)
                }
                Spacer(minLength: 0)
            }
            .padding(.top, 16)
            .background(AppColor.background.ignoresSafeArea())
            .navigationTitle("Orbit Tap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear { reset() }
        }
    }

    private func reset() {
        caught = 0
        isComplete = false
        orbs = (0..<target).map { index in
            Orb(
                position: CGPoint(x: 40 + CGFloat(index % 5) * 60, y: 60 + CGFloat(index / 5) * 100),
                size: .random(in: 30...46),
                opacity: .random(in: 0.55...1)
            )
        }
    }

    private func catchOrb(_ orb: Orb) {
        guard !isComplete else { return }
        orbs.removeAll { $0.id == orb.id }
        caught += 1
        if caught >= target { isComplete = true }
    }
}

private struct Orb: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
}

#Preview {
    OrbitTapView()
}
