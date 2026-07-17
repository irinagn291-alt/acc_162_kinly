import Foundation

/// A bundled-locally set of warm conversation-starter suggestions.
/// No network call is ever made — the list ships with the app.
struct ConversationStarterProvider {
    enum Category: String, CaseIterable {
        case checkIn
        case celebration
        case support
        case memories
        case distance
        case family
    }

    private let promptsByCategory: [Category: [String]] = [
        .checkIn: [
            "Ask about something nice that happened for them this week.",
            "Ask what they're watching, reading, or listening to lately.",
            "Ask about their plans for the upcoming weekend.",
            "Ask how their energy has been lately — no pressure to explain.",
            "Check in on a project or hobby they mentioned last time.",
            "Ask what ordinary moment made them smile recently.",
            "Ask how work or school has been treating them.",
            "Gently ask what their days have felt like lately.",
            "Ask if they've found a new favorite café, recipe, or walk.",
            "Ask what they're looking forward to in the next few weeks.",
            "Share a small bit of your week and invite them to share theirs.",
            "Ask how they're sleeping and resting — keep it light.",
            "Ask what song has been stuck in their head.",
            "Ask if anything unexpected made their week better.",
            "Ask what they'd love a free afternoon for right now.",
        ],
        .celebration: [
            "Congratulate them on something small they finished recently.",
            "Celebrate a habit they've stuck with, even quietly.",
            "Ask what win — tiny or big — they want to toast this month.",
            "Tell them you're proud of how they're showing up lately.",
            "Ask about a milestone coming up and how they want to mark it.",
            "Share excitement about something they're building toward.",
            "Ask what success looks like for them this season.",
            "Celebrate the courage it took to try something new.",
            "Ask if there's good news they've been meaning to share.",
            "Tell them a strength you notice in them and ask how it shows up.",
            "Ask what they're quietly proud of that others might miss.",
            "Invite them to brag for sixty seconds — no modesty allowed.",
            "Celebrate how far they've come since you last talked.",
            "Ask what gift of time they'd give themselves as a reward.",
        ],
        .support: [
            "Gently ask if there's anything they could use support with.",
            "Ask what would brighten their day right now.",
            "Offer to listen without fixing — just presence.",
            "Ask if there's a hard thing they've been carrying alone.",
            "Check whether they need practical help or just company.",
            "Ask what kind of check-in feels kindest for them lately.",
            "Share that you're available for a low-pressure call.",
            "Ask what makes them feel steadier when things pile up.",
            "Invite them to vent for five minutes if they want.",
            "Ask whether rest or momentum would help more right now.",
            "Tell them they don't have to be okay for you to care.",
            "Ask what one small kindness they could accept this week.",
            "Offer to help with something ordinary — errands, packing, planning.",
            "Ask if they want distraction, advice, or quiet company.",
        ],
        .memories: [
            "Recall a shared memory and ask if they remember it too.",
            "Ask about their last trip or a place they enjoyed.",
            "Bring up an old joke only the two of you get.",
            "Ask what photo from your shared past still makes them laugh.",
            "Remind them of a day that felt easy between you.",
            "Ask which season of your friendship they miss most fondly.",
            "Share a tiny detail you still remember about them.",
            "Ask about the first time you knew they'd be important to you.",
            "Recall a meal you shared and ask what they'd order again.",
            "Ask which song takes them back to a moment with you.",
            "Mention a place you'd love to revisit together someday.",
            "Ask what childhood story of theirs you'd love to hear again.",
            "Bring up a tradition you used to have and ask if they miss it.",
            "Ask which memory of you two they'd put in a time capsule.",
        ],
        .distance: [
            "Share why they've been on your mind today.",
            "Ask what time of day feels best for a long-distance catch-up.",
            "Send a voice note idea: one highlight from their week.",
            "Ask what local weather or street scene they'd show you on video.",
            "Share a photo of your day and ask for one of theirs.",
            "Ask what they'd want you to experience if you visited soon.",
            "Propose a tiny ritual — same song, same snack, different cities.",
            "Ask how time zones have been treating your connection.",
            "Tell them distance hasn't dimmed how much they matter.",
            "Ask what news from their city you'd never see online.",
            "Invite a short co-watch or co-listen session sometime.",
            "Ask what care package item they'd send you if they could.",
            "Share a postcard-style update of your week in three lines.",
            "Ask when a real visit might feel possible — no pressure.",
        ],
        .family: [
            "Ask how their loved ones are doing — family, kids, pets.",
            "Ask about a parent, sibling, or relative they've mentioned.",
            "Check in on how family gatherings have felt lately.",
            "Ask what their kids or nieces and nephews are into right now.",
            "Ask how the household rhythm has been this month.",
            "Invite a story about a pet antics or cozy home moment.",
            "Ask what family tradition they're keeping or reinventing.",
            "Check how caregiving or family logistics have been weighing.",
            "Ask who in the family has made them laugh recently.",
            "Share warmth for their people and ask whom to send hello to.",
            "Ask what home looks like for them these days.",
            "Ask if there's a family win worth celebrating together.",
            "Gently ask how boundaries with family have been going.",
            "Ask what they hope their family remembers about this year.",
        ],
    ]

    /// Returns a shuffled sample across all categories.
    func suggestions(count: Int = 3) -> [String] {
        let all = promptsByCategory.values.flatMap(\.self)
        return Array(all.shuffled().prefix(max(0, count)))
    }

    /// Optional category-scoped sample for future UI chips.
    func suggestions(in category: Category, count: Int = 3) -> [String] {
        let prompts = promptsByCategory[category] ?? []
        return Array(prompts.shuffled().prefix(max(0, count)))
    }
}
