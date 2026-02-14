import SwiftUI

struct NexAvatar: View {
    let name: String
    let colorName: String
    var size: CGFloat = 40
    
    init(name: String, colorName: String, size: CGFloat = 40) {
        self.name = name
        self.colorName = colorName
        self.size = size
    }
    
    init(person: Person, size: CGFloat = 40) {
        self.name = person.name
        self.colorName = person.colorName
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.fromTailwind(colorName), Color.fromTailwind(colorName).opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            Text(name.prefix(1).uppercased())
                .font(.system(size: size * 0.45, weight: .bold))
                .foregroundColor(.white)
        }
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: size * 0.05)
        )
        .shadow(color: Color.fromTailwind(colorName).opacity(0.3), radius: size * 0.1, x: 0, y: size * 0.05)
    }
}
