import SwiftUI

/// Soft mini-game: drag stars onto silhouette target positions.
/// Completing the align shows a glow and a conversation starter.
struct ConstellationAlignView: View {
    let conversationStarterProvider: ConversationStarterProvider
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var starCount = 5
    @State private var placements: [UUID: CGPoint] = [:]
    @State private var settled: Set<UUID> = []
    @State private var starIDs: [UUID] = []
    @State private var targets: [CGPoint] = []
    @State private var canvasSize: CGSize = .zero
    @State private var isComplete = false
    @State private var rewardPrompt: String?
    @State private var glowPulse = false
    @State private var dragOrigins: [UUID: CGPoint] = [:]

    private let snapDistance: CGFloat = 36

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                GeometryReader { geo in
                    let size = geo.size
                    ZStack {
                        silhouette(in: size)
                            .opacity(isComplete ? 0.55 : 0.28)

                        ForEach(Array(targets.enumerated()), id: \.offset) { index, target in
                            Circle()
                                .strokeBorder(AppColor.primary.opacity(settledContains(index) ? 0.9 : 0.35), lineWidth: 1.5)
                                .frame(width: 28, height: 28)
                                .position(target)
                        }

                        ForEach(starIDs, id: \.self) { id in
                            starView(id: id)
                        }

                        if isComplete {
                            completionOverlay
                                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                        }
                    }
                    .onAppear {
                        if canvasSize == .zero {
                            configureBoard(in: size)
                        }
                    }
                    .onChange(of: size) { _, newSize in
                        if canvasSize != newSize, !isComplete {
                            configureBoard(in: newSize)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Align")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                if reduceMotion {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Align for me") { alignForMe() }
                            .disabled(isComplete)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var completionOverlay: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(AppColor.primary.opacity(glowPulse ? 0.55 : 0.25))
                .frame(width: glowPulse ? 160 : 120, height: glowPulse ? 160 : 120)
                .blur(radius: 28)
                .overlay {
                    Image(systemName: "sparkles")
                        .font(.system(size: 36))
                        .foregroundStyle(AppColor.accent)
                }

            Text("Constellation aligned")
                .font(.headline)
                .foregroundStyle(AppColor.text)

            if let rewardPrompt {
                Text(rewardPrompt)
                    .font(.subheadline)
                    .foregroundStyle(AppColor.text.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding(24)
        .background(AppColor.surface.opacity(0.92), in: RoundedRectangle(cornerRadius: 20))
        .padding()
    }

    private func silhouette(in size: CGSize) -> some View {
        let center = CGPoint(x: size.width / 2, y: size.height * 0.42)
        return ZStack {
            Capsule()
                .fill(AppColor.secondary.opacity(0.35))
                .frame(width: size.width * 0.28, height: size.height * 0.42)
                .position(x: center.x, y: center.y + size.height * 0.08)
            Circle()
                .fill(AppColor.secondary.opacity(0.4))
                .frame(width: size.width * 0.22, height: size.width * 0.22)
                .position(x: center.x, y: center.y - size.height * 0.16)
        }
        .allowsHitTesting(false)
    }

    private func starView(id: UUID) -> some View {
        let point = placements[id] ?? .zero
        let isSettled = settled.contains(id)
        return Circle()
            .fill(AppColor.text.opacity(isSettled ? 1 : 0.85))
            .frame(width: 22, height: 22)
            .shadow(color: AppColor.primary.opacity(isSettled ? 0.9 : 0.35), radius: isSettled ? 10 : 4)
            .frame(width: 44, height: 44)
            .contentShape(Circle())
            .position(point)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard !isComplete, !settled.contains(id) else { return }
                        if dragOrigins[id] == nil { dragOrigins[id] = placements[id] }
                        guard let origin = dragOrigins[id] else { return }
                        placements[id] = CGPoint(
                            x: origin.x + value.translation.width,
                            y: origin.y + value.translation.height
                        )
                    }
                    .onEnded { value in
                        guard !isComplete, !settled.contains(id) else { return }
                        let origin = dragOrigins[id] ?? placements[id] ?? .zero
                        let end = CGPoint(
                            x: origin.x + value.translation.width,
                            y: origin.y + value.translation.height
                        )
                        dragOrigins[id] = nil
                        snapIfNeeded(id: id, at: end)
                    }
            )
    }

    private func settledContains(_ index: Int) -> Bool {
        guard index < targets.count else { return false }
        return settled.contains { id in
            guard let point = placements[id] else { return false }
            return hypot(point.x - targets[index].x, point.y - targets[index].y) < 2
        }
    }

    private func configureBoard(in size: CGSize) {
        canvasSize = size
        starCount = Int.random(in: 4...6)
        starIDs = (0..<starCount).map { _ in UUID() }
        targets = targetPositions(count: starCount, in: size)
        settled = []
        isComplete = false
        rewardPrompt = nil
        glowPulse = false

        let trayY = size.height * 0.88
        let spacing = size.width / CGFloat(starCount + 1)
        placements = Dictionary(uniqueKeysWithValues: starIDs.enumerated().map { index, id in
            (id, CGPoint(x: spacing * CGFloat(index + 1), y: trayY))
        })
    }

    private func targetPositions(count: Int, in size: CGSize) -> [CGPoint] {
        let center = CGPoint(x: size.width / 2, y: size.height * 0.42)
        // Soft constellation silhouette: head + torso outline points.
        let base: [CGPoint] = [
            CGPoint(x: center.x, y: center.y - size.height * 0.18),
            CGPoint(x: center.x - size.width * 0.1, y: center.y - size.height * 0.02),
            CGPoint(x: center.x + size.width * 0.1, y: center.y - size.height * 0.02),
            CGPoint(x: center.x - size.width * 0.07, y: center.y + size.height * 0.14),
            CGPoint(x: center.x + size.width * 0.07, y: center.y + size.height * 0.14),
            CGPoint(x: center.x, y: center.y + size.height * 0.22),
        ]
        return Array(base.prefix(count))
    }

    private func snapIfNeeded(id: UUID, at location: CGPoint) {
        var bestIndex: Int?
        var bestDistance = snapDistance
        for (index, target) in targets.enumerated() {
            let occupied = settled.contains { settledID in
                guard let point = placements[settledID] else { return false }
                return hypot(point.x - target.x, point.y - target.y) < 2
            }
            if occupied { continue }
            let distance = hypot(location.x - target.x, location.y - target.y)
            if distance < bestDistance {
                bestDistance = distance
                bestIndex = index
            }
        }

        if let bestIndex {
            withAnimation(.easeOut(duration: reduceMotion ? 0.05 : 0.22)) {
                placements[id] = targets[bestIndex]
                settled.insert(id)
            }
            HapticsService.shared.playStarBrighten()
            checkCompletion()
        } else {
            placements[id] = location
        }
    }

    private func alignForMe() {
        for (index, id) in starIDs.enumerated() where index < targets.count {
            placements[id] = targets[index]
            settled.insert(id)
        }
        checkCompletion()
    }

    private func checkCompletion() {
        guard settled.count == starIDs.count, !isComplete else { return }
        rewardPrompt = conversationStarterProvider.suggestions(count: 1).first
        withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.45)) {
            isComplete = true
            glowPulse = true
        }
        HapticsService.shared.playStarBrighten()
    }
}

#Preview {
    ConstellationAlignView(conversationStarterProvider: ConversationStarterProvider())
}
