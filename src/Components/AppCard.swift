import SwiftUI

struct AppCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let background: AnyView
    
    init(
        padding: CGFloat = 16,
        isGlass: Bool = false,
        backgroundColor: Color = Color.white,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        if isGlass {
            self.background = AnyView(
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                    .glassmorphicBorder()
            )
        } else {
            self.background = AnyView(backgroundColor)
        }
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(background)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: Context) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { uiView.effect = effect }
}
