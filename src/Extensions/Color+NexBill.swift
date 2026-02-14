import SwiftUI

extension Color {
    // Brand Colors
    static let nexIndigo = Color(red: 99/255, green: 102/255, blue: 241/255)
    static let nexIndigoDark = Color(red: 79/255, green: 70/255, blue: 229/255)
    static let nexPurple = Color(red: 168/255, green: 85/255, blue: 247/255)
    static let nexEmerald = Color(red: 16/255, green: 185/255, blue: 129/255)
    static let nexTeal = Color(red: 20/255, green: 184/255, blue: 166/255)
    
    // Neutrals
    static let nexSlate50 = Color(red: 248/255, green: 250/255, blue: 252/255)
    static let nexSlate100 = Color(red: 241/255, green: 245/255, blue: 249/255)
    static let nexSlate200 = Color(red: 226/255, green: 232/255, blue: 240/255)
    static let nexSlate400 = Color(red: 148/255, green: 163/255, blue: 184/255)
    static let nexSlate500 = Color(red: 100/255, green: 116/255, blue: 139/255)
    static let nexSlate800 = Color(red: 30/255, green: 41/255, blue: 59/255)
    static let nexSlate900 = Color(red: 15/255, green: 23/255, blue: 42/255)
    
    // Gradients
    static let nexPrimaryGradient = LinearGradient(
        colors: [.nexIndigo, .nexPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let nexSuccessGradient = LinearGradient(
        colors: [.nexEmerald, .nexTeal],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static func fromTailwind(_ name: String) -> Color {
        switch name {
        case "indigo-500": return .nexIndigo
        case "purple-500": return .nexPurple
        case "emerald-500": return .nexEmerald
        case "teal-500": return .nexTeal
        case "pink-500": return .pink
        case "blue-500": return .blue
        case "orange-500": return .orange
        case "slate-500": return .gray
        default: return .nexIndigo
        }
    }
}

extension View {
    func glassmorphicBorder() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.5), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}
