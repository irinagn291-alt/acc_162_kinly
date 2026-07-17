import SwiftUI

struct ConstellationView: View {
    let dependencies: AppDependencies
    @State private var viewModel: ConstellationViewModel

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = State(initialValue: ConstellationViewModel(dependencies: dependencies))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView().tint(AppColor.text)
                } else if viewModel.stars.isEmpty {
                    ContentUnavailableView(
                        "Your constellation is empty",
                        systemImage: "sparkles",
                        description: Text("Add the people you care about — and they'll light up here.")
                    )
                    .foregroundStyle(AppColor.text)
                } else {
                    GeometryReader { geo in
                        let points = layoutPoints(count: viewModel.stars.count, in: geo.size)
                        Canvas { context, _ in
                            for (index, star) in viewModel.stars.enumerated() {
                                var ctx = context
                                StarDrawing.drawGlowingStar(
                                    in: &ctx,
                                    at: points[index],
                                    brightness: star.brightness,
                                    radius: 7 + CGFloat(star.brightness) * 5
                                )
                            }
                        }
                        .gesture(
                            SpatialTapGesture().onEnded { value in
                                if let index = nearestStarIndex(to: value.location, points: points) {
                                    viewModel.select(viewModel.stars[index].person)
                                }
                            }
                        )
                        .accessibilityElement(children: .contain)
                        .overlay {
                            ForEach(Array(viewModel.stars.enumerated()), id: \.element.id) { index, star in
                                Button {
                                    viewModel.select(star.person)
                                } label: {
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 44, height: 44)
                                }
                                .accessibilityLabel(star.person.name)
                                .accessibilityHint("Opens connection details")
                                .position(points[index])

                                Text(star.person.name)
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(AppColor.text.opacity(0.85))
                                    .accessibilityHidden(true)
                                    .position(x: points[index].x, y: points[index].y + 22)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Constellation")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.showAlignGame = true
                    } label: {
                        Image(systemName: "circle.grid.cross")
                    }
                    .accessibilityLabel("Align constellation")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showAddPerson = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add person")
                }
            }
            .task { await viewModel.load() }
            .sheet(item: $viewModel.selectedPerson) { person in
                personDetail(person)
            }
            .sheet(isPresented: $viewModel.showAddPerson) {
                addPersonSheet
            }
            .sheet(isPresented: $viewModel.showAlignGame) {
                ConstellationAlignView(
                    conversationStarterProvider: dependencies.conversationStarterProvider
                )
            }
        }
        .preferredColorScheme(.dark)
    }

    private func personDetail(_ person: Person) -> some View {
        NavigationStack {
            Form {
                Section("Contact") {
                    Text(person.name)
                    Text("Rhythm: \(RussianPlural.days(person.contactRhythmDays))")
                        .foregroundStyle(.secondary)
                }

                if let feedback = viewModel.brightenFeedback {
                    Section {
                        Text(feedback)
                            .font(.subheadline)
                            .foregroundStyle(AppColor.primary)
                    }
                }

                Section("Log a connection") {
                    TextField("Note (optional)", text: $viewModel.noteDraft)
                    Toggle("Important date", isOn: $viewModel.markImportant)
                    Button("We connected") {
                        Task { await viewModel.logContact() }
                    }
                    .disabled(viewModel.brightenFeedback != nil)
                }

                Section("Something to talk about") {
                    ForEach(viewModel.conversationStarters, id: \.self) { starter in
                        Text(starter)
                    }
                }

                Section("Reach out") {
                    ShareLink(item: viewModel.reachOutShareText) {
                        Label("Share a gentle nudge", systemImage: "square.and.arrow.up")
                    }
                }

                if !viewModel.timeline.isEmpty {
                    Section("Timeline") {
                        ForEach(viewModel.timeline) { interaction in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(interaction.date, style: .date)
                                    .font(.subheadline.weight(.medium))
                                if let note = interaction.note, !note.isEmpty {
                                    Text(note)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                if interaction.isImportantDate {
                                    Text("Important date")
                                        .font(.caption)
                                        .foregroundStyle(AppColor.accent)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }

                Section {
                    Button("Remove from constellation", role: .destructive) {
                        Task { await viewModel.deleteSelectedPerson() }
                    }
                }
            }
            .navigationTitle(person.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { viewModel.dismissDetail() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var addPersonSheet: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $viewModel.newPersonName)
                Stepper(
                    "Rhythm: \(RussianPlural.days(viewModel.newPersonRhythm))",
                    value: $viewModel.newPersonRhythm,
                    in: 1...60
                )
            }
            .navigationTitle("Someone new")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showAddPerson = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task { await viewModel.addPerson() }
                    }
                    .disabled(viewModel.newPersonName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func layoutPoints(count: Int, in size: CGSize) -> [CGPoint] {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        guard count > 0 else { return [] }
        if count == 1 { return [center] }
        return (0..<count).map { index in
            let angle = (Double(index) / Double(count)) * .pi * 2 - .pi / 2
            let radius = min(size.width, size.height) * 0.32
            return CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
        }
    }

    private func nearestStarIndex(to location: CGPoint, points: [CGPoint]) -> Int? {
        var best: (Int, CGFloat)?
        for (index, point) in points.enumerated() {
            let distance = hypot(point.x - location.x, point.y - location.y)
            if distance < 44, best == nil || distance < best!.1 {
                best = (index, distance)
            }
        }
        return best?.0
    }
}

#Preview {
    ConstellationView(dependencies: PreviewSupport.makeDependencies())
}
