import SwiftUI

struct OnboardingView: View {
    let dependencies: AppDependencies
    let onFinished: () -> Void

    @State private var viewModel: OnboardingViewModel
    @State private var showContactsImport = false

    init(dependencies: AppDependencies, onFinished: @escaping () -> Void) {
        self.dependencies = dependencies
        self.onFinished = onFinished
        _viewModel = State(initialValue: OnboardingViewModel(dependencies: dependencies))
    }

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            VStack(spacing: 0) {
                progress
                    .padding(.top, 16)
                    .padding(.horizontal, 24)

                Group {
                    switch viewModel.step {
                    case 0: peopleStep
                    case 1: rhythmStep
                    case 2: remindersStep
                    default: constellationPreviewStep
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.easeInOut, value: viewModel.step)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showContactsImport) {
            ImportContactsSheet(dependencies: dependencies) { contacts in
                for contact in contacts {
                    viewModel.addDraftPerson(named: contact.name)
                }
            }
        }
        .alert("Something went wrong", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var progress: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.stepTitles[viewModel.step])
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppColor.text)
            ProgressView(value: Double(viewModel.step + 1), total: Double(viewModel.stepTitles.count))
                .tint(AppColor.primary)
        }
    }

    private var peopleStep: some View {
        VStack(spacing: 20) {
            Text("Add up to three people — the ones you want to stay gently connected with.")
                .font(.subheadline)
                .foregroundStyle(AppColor.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            HStack {
                TextField("Name", text: $viewModel.newPersonName)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(AppColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(AppColor.text)
                Button("Add") { viewModel.addDraftPerson() }
                    .buttonStyle(KinlySecondaryButtonStyle())
                    .frame(width: 110)
                    .disabled(!viewModel.canAddMorePeople)
            }
            .padding(.horizontal, 24)

            Button("Import from Contacts") { showContactsImport = true }
                .font(.subheadline)
                .foregroundStyle(AppColor.accent)

            List {
                ForEach(viewModel.draftPeople) { person in
                    HStack {
                        Text(person.name).foregroundStyle(AppColor.text)
                        Spacer()
                        Button(role: .destructive) {
                            viewModel.removeDraftPerson(person)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(AppColor.text.opacity(0.4))
                        }
                    }
                    .listRowBackground(AppColor.surface)
                }
            }
            .scrollContentBackground(.hidden)

            Spacer()

            Button("Continue") { viewModel.goNext() }
                .buttonStyle(KinlyPrimaryButtonStyle())
                .disabled(!viewModel.canGoToRhythmStep)
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
        }
        .padding(.top, 24)
    }

    private var rhythmStep: some View {
        VStack(spacing: 16) {
            Text("How often would you like to stay in touch with each person?")
                .font(.subheadline)
                .foregroundStyle(AppColor.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            List {
                ForEach(viewModel.draftPeople) { person in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(person.name)
                            .foregroundStyle(AppColor.text)
                        Stepper(
                            RussianPlural.days(person.rhythmDays),
                            value: Binding(
                                get: { person.rhythmDays },
                                set: { viewModel.updateRhythm(for: person.id, days: $0) }
                            ),
                            in: 1...60
                        )
                        .foregroundStyle(AppColor.text.opacity(0.85))
                    }
                    .listRowBackground(AppColor.surface)
                }
            }
            .scrollContentBackground(.hidden)

            HStack(spacing: 12) {
                Button("Back") { viewModel.goBack() }
                    .buttonStyle(KinlySecondaryButtonStyle())
                Button("Continue") { viewModel.goNext() }
                    .buttonStyle(KinlyPrimaryButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .padding(.top, 24)
    }

    private var remindersStep: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "bell.badge")
                .font(.system(size: 44))
                .foregroundStyle(AppColor.primary)
            Text("Gentle reminders")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppColor.text)
            Text("Kinly can softly remind you when it might be nice to write or call — never with guilt.")
                .font(.body)
                .foregroundStyle(AppColor.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            VStack(spacing: 12) {
                Button("Allow reminders") {
                    Task { await viewModel.requestNotifications() }
                }
                .buttonStyle(KinlyPrimaryButtonStyle())

                Button("Not now") { viewModel.goNext() }
                    .buttonStyle(KinlySecondaryButtonStyle())

                Button("Back") { viewModel.goBack() }
                    .font(.subheadline)
                    .foregroundStyle(AppColor.text.opacity(0.55))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
    }

    private var constellationPreviewStep: some View {
        VStack(spacing: 24) {
            Spacer()
            Canvas { context, size in
                let points = previewPoints(in: size, count: max(viewModel.draftPeople.count, 1))
                for (index, point) in points.enumerated() {
                    var ctx = context
                    StarDrawing.drawGlowingStar(
                        in: &ctx,
                        at: point,
                        brightness: 0.7 + Double(index % 3) * 0.1,
                        radius: 8
                    )
                }
            }
            .frame(height: 220)
            .background(AppColor.surface.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 24)

            Text("Your constellation is almost ready")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppColor.text)
            Text(viewModel.draftPeople.map(\.name).joined(separator: " · "))
                .font(.subheadline)
                .foregroundStyle(AppColor.accent)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            Spacer()

            Button(viewModel.isSaving ? "Saving…" : "Open Kinly") {
                Task {
                    if await viewModel.finishOnboarding() {
                        onFinished()
                    }
                }
            }
            .buttonStyle(KinlyPrimaryButtonStyle())
            .disabled(viewModel.isSaving)
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
    }

    private func previewPoints(in size: CGSize, count: Int) -> [CGPoint] {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        guard count > 1 else { return [center] }
        return (0..<count).map { index in
            let angle = (Double(index) / Double(count)) * .pi * 2 - .pi / 2
            return CGPoint(
                x: center.x + cos(angle) * size.width * 0.28,
                y: center.y + sin(angle) * size.height * 0.28
            )
        }
    }
}

#Preview {
    OnboardingView(dependencies: PreviewSupport.makeDependencies(), onFinished: {})
}
