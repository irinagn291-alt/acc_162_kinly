import SwiftUI

/// Reusable, explicit opt-in contacts import flow. Always presented from a
/// deliberate user tap — never triggered automatically.
struct ImportContactsSheet: View {
    let dependencies: AppDependencies
    let onImport: ([ImportableContact]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var contacts: [ImportableContact] = []
    @State private var selectedIDs: Set<String> = []
    @State private var isLoading = true
    @State private var accessDenied = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Contacts")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            onImport(contacts.filter { selectedIDs.contains($0.id) })
                            dismiss()
                        }
                        .disabled(selectedIDs.isEmpty)
                    }
                }
                .task { await loadContacts() }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColor.background)
        } else if accessDenied {
            ContentUnavailableView(
                "Contacts access isn't allowed",
                systemImage: "person.crop.circle.badge.xmark",
                description: Text("That's optional — you can always add people by hand.")
            )
        } else {
            List(contacts) { contact in
                Button {
                    toggle(contact)
                } label: {
                    HStack {
                        Text(contact.name)
                            .foregroundStyle(AppColor.text)
                        Spacer()
                        Image(systemName: selectedIDs.contains(contact.id) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedIDs.contains(contact.id) ? AppColor.primary : .secondary)
                    }
                }
                .buttonStyle(.plain)
                .listRowBackground(AppColor.surface)
            }
            .scrollContentBackground(.hidden)
            .background(AppColor.background)
        }
    }

    private func toggle(_ contact: ImportableContact) {
        if selectedIDs.contains(contact.id) {
            selectedIDs.remove(contact.id)
        } else {
            selectedIDs.insert(contact.id)
        }
    }

    private func loadContacts() async {
        isLoading = true
        defer { isLoading = false }

        let status = await dependencies.contactsImportRepository.requestAccess()
        guard status == .authorized else {
            accessDenied = true
            return
        }

        do {
            contacts = try await dependencies.contactsImportRepository.fetchImportableContacts()
        } catch {
            accessDenied = true
        }
    }
}

#Preview {
    ImportContactsSheet(dependencies: PreviewSupport.makeDependencies(), onImport: { _ in })
}
