import SwiftUI

struct ToolPanel<Content: View>: View {
    let title: String
    @Binding var isPresented: Bool
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            if isPresented {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(title)
                            .font(MomentumTypography.title)
                            .foregroundStyle(MomentumColors.textPrimary)
                        Spacer()
                        Button {
                            withAnimation(MomentumMotion.panelEnter) {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(MomentumColors.textSecondary)
                                .padding(8)
                                .background(Circle().fill(MomentumColors.backgroundSecondary))
                        }
                    }

                    content()
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(MomentumColors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(MomentumColors.backgroundSecondary, lineWidth: 1)
                        )
                        .momentumShadow(MomentumShadow.card)
                )
                .padding(.horizontal, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(MomentumMotion.panelEnter, value: isPresented)
    }
}
