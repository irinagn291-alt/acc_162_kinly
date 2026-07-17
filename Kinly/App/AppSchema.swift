import SwiftData

/// Central registry of SwiftData model types for Kinly.
/// Add each new @Model type to `allModels` as it is implemented.
enum AppSchema {
    static let allModels: [any PersistentModel.Type] = [
        PersonModel.self,
        InteractionModel.self
    ]
}
