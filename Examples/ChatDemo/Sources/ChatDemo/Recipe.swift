import OpenFoundationModels

/// A typed target for guided generation. The `@Generable` macro synthesizes a
/// `GenerationSchema` from the stored properties below; `@Guide` attaches
/// natural-language hints the model is steered toward when filling each field.
@Generable
struct Recipe: Equatable {
    @Guide(description: "a short, appetizing dish name")
    var name: String

    @Guide(description: "the ingredients, each as a short shopping-list style line")
    var ingredients: [String]

    @Guide(description: "total time to prepare and cook, in minutes", .range(1...480))
    var minutes: Int
}
