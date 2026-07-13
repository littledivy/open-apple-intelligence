import SwiftUI
import OpenFoundationModels

@MainActor
@Observable
final class GuidedGenViewModel {
    var prompt: String = "A quick weeknight pasta dinner"
    private(set) var recipe: Recipe?
    private(set) var isGenerating = false
    var errorText: String?

    private var session = LanguageModelSession(
        instructions: "You invent simple, realistic recipes."
    )

    func resetSession() {
        session = LanguageModelSession(
            instructions: "You invent simple, realistic recipes."
        )
    }

    func generate() {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isGenerating else { return }

        errorText = nil
        isGenerating = true
        Task {
            defer { isGenerating = false }
            do {
                let response = try await session.respond(to: trimmed, generating: Recipe.self)
                recipe = response.content
            } catch {
                errorText = ChatViewModel.describe(error)
            }
        }
    }
}

struct GuidedGenView: View {
    @Environment(BackendSettings.self) private var backend
    @State private var viewModel = GuidedGenViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Guided generation")
                    .font(.title3.weight(.semibold))
                Text("Asks the model for a `Recipe` value directly — no manual JSON parsing. The `@Generable` macro derives the schema; `@Guide` steers individual fields.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                TextField("What should the recipe be?", text: $viewModel.prompt)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { viewModel.generate() }

                Button {
                    viewModel.generate()
                } label: {
                    if viewModel.isGenerating {
                        ProgressView()
                            .controlSize(.small)
                            .frame(width: 60)
                    } else {
                        Text("Generate")
                            .frame(width: 60)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isGenerating || viewModel.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if let errorText = viewModel.errorText {
                Label(errorText, systemImage: "exclamationmark.triangle.fill")
                    .font(.callout)
                    .foregroundStyle(.orange)
                    .textSelection(.enabled)
            }

            if let recipe = viewModel.recipe {
                RecipeCard(recipe: recipe)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            } else if !viewModel.isGenerating {
                emptyState
            }

            Spacer(minLength: 0)
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.recipe)
        .padding(20)
        .onChange(of: backend.revision) {
            viewModel.resetSession()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "fork.knife")
                .font(.system(size: 32))
                .foregroundStyle(.tertiary)
            Text("Generate a recipe to see the typed result")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}

private struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(recipe.name)
                    .font(.title2.weight(.bold))
                Spacer()
                Label("\(recipe.minutes) min", systemImage: "clock")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("Ingredients")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                ForEach(Array(recipe.ingredients.enumerated()), id: \.offset) { _, ingredient in
                    Label(ingredient, systemImage: "circle.fill")
                        .labelStyle(BulletLabelStyle())
                        .font(.callout)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct BulletLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: 8) {
            configuration.icon
                .font(.system(size: 5))
                .foregroundStyle(.secondary)
                .padding(.top, 6)
            configuration.title
        }
    }
}

#Preview {
    GuidedGenView()
        .environment(BackendSettings())
        .frame(width: 560, height: 560)
}
