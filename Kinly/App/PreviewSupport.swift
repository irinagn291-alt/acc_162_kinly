import SwiftData

/// Shared helpers for building in-memory dependencies for SwiftUI `#Preview`s.
@MainActor
enum PreviewSupport {
    static func makeContainer() -> ModelContainer {
        let schema = Schema(AppSchema.allModels)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create preview ModelContainer: \(error)")
        }
    }

    static func makeDependencies() -> AppDependencies {
        AppDependencies(modelContext: ModelContext(makeContainer()))
    }
}
