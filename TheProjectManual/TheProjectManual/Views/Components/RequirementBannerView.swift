import SwiftUI

struct RequirementBannerView: View {
    let requirements: [StepCompletionRequirement]

    var body: some View {
        if !requirements.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Label("Complete before advancing", systemImage: "exclamationmark.triangle")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)

                ForEach(requirements) { requirement in
                    Text("• \(requirement.message)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
            .accessibilityElement(children: .combine)
        }
    }
}

#Preview {
    RequirementBannerView(
        requirements: [
            StepCompletionRequirement(id: "1", message: "Verify: Frame square"),
            StepCompletionRequirement(id: "2", message: "Record actual value for Left end frame outside width")
        ]
    )
    .padding()
}
