import SwiftUI

struct LandingView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background with subtle radial gradients
                Color.nexSlate50.ignoresSafeArea()
                Circle()
                    .fill(Color.nexIndigo.opacity(0.1))
                    .blur(radius: 100)
                    .offset(x: -150, y: -200)
                Circle()
                    .fill(Color.nexPurple.opacity(0.1))
                    .blur(radius: 100)
                    .offset(x: 150, y: 200)
                
                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.nexPrimaryGradient)
                                .frame(width: 36, height: 36)
                            Text("N")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                        Text("NexSplit")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.nexSlate900)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Hero Section
                    VStack(spacing: 28) {
                        VStack(spacing: 4) {
                            Text("Split bills")
                                .font(.system(size: 52, weight: .black))
                                .foregroundColor(.nexSlate900)
                            Text("intelligently.")
                                .font(.system(size: 52, weight: .black))
                                .foregroundStyle(Color.nexPrimaryGradient)
                        }
                        .multilineTextAlignment(.center)
                        
                        Text("Upload any receipt, let our AI extract the items, and assign costs to friends in seconds.")
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .lineSpacing(4)
                        
                        VStack(spacing: 16) {
                            NexButton("Get Started", icon: "sparkles", size: .lg) {
                                appState.navigate(to: .dashboard)
                            }
                            .shadow(color: .nexIndigo.opacity(0.3), radius: 20, x: 0, y: 10)
                            
                            NexButton("View Features", variant: .outline, size: .lg) {
                                // Scroll to features or show info
                            }
                        }
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("TOP FEATURES")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.secondary)
                            .kerning(1.5)
                            .padding(.horizontal, 32)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                FeatureCard(icon: "doc.text.viewfinder", title: "AI Scanning", description: "Digitize paper receipts instantly with NexSplit AI.")
                                FeatureCard(icon: "person.2.fill", title: "Smart Groups", description: "Assign items to specific friends easily.")
                                FeatureCard(icon: "chart.pie.fill", title: "Visual Split", description: "See who owes what with interactive charts.")
                                FeatureCard(icon: "checkmark.seal.fill", title: "Quick Settle", description: "Export summaries and settle with one tap.")
                            }
                            .padding(.horizontal, 32)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        AppCard(padding: 24, isGlass: true) {
            VStack(alignment: .leading, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.nexIndigo.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.nexIndigo)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.nexSlate900)
                    
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(width: 160)
        }
    }
}
