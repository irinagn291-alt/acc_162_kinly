import Foundation

/// Small helper for English plural word forms, shared across the app's copy.
enum RussianPlural {
    static func wordForm(_ count: Int, singular: String, plural: String) -> String {
        count == 1 ? singular : plural
    }

    static func days(_ count: Int) -> String {
        "\(count) " + wordForm(count, singular: "day", plural: "days")
    }

    static func weeks(_ count: Int) -> String {
        "\(count) " + wordForm(count, singular: "week", plural: "weeks")
    }

    static func months(_ count: Int) -> String {
        "\(count) " + wordForm(count, singular: "month", plural: "months")
    }
}
