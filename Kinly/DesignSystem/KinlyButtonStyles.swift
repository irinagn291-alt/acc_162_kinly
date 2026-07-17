import SwiftUI

struct KinlyPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(AppColor.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColor.primary.opacity(configuration.isPressed ? 0.75 : 1))
            )
    }
}

struct KinlySecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(AppColor.text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppColor.text.opacity(0.2), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
