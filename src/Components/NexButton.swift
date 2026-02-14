import SwiftUI

struct NexButton: View {
    enum Variant {
        case primary, secondary, outline, ghost
    }
    
    enum Size {
        case sm, md, lg
    }
    
    let title: String
    let icon: String?
    let variant: Variant
    let size: Size
    let action: () -> Void
    
    init(
        _ title: String,
        icon: String? = nil,
        variant: Variant = .primary,
        size: Size = .md,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(minWidth: size == .lg ? 200 : 0)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .overlay(
                 RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: variant == .outline ? 1 : 0)
            )
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .sm: return 12; case .md: return 16; case .lg: return 24
        }
    }
    
    private var verticalPadding: CGFloat {
        switch size {
        case .sm: return 6; case .md: return 10; case .lg: return 14
        }
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .primary: return .nexIndigo
        case .secondary: return .nexIndigo.opacity(0.1)
        case .outline, .ghost: return .clear
        }
    }
    
    private var foregroundColor: Color {
        switch variant {
        case .primary: return .white
        case .secondary: return .nexIndigo
        case .outline, .ghost: return .primary
        }
    }
    
    private var borderColor: Color {
        variant == .outline ? Color.gray.opacity(0.3) : .clear
    }
}
