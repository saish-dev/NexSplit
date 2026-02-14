import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.nexSlate50.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 40) {
                            // Header
                            VStack(alignment: .leading, spacing: 8) {
                                Text("NexSplit")
                                    .font(.system(size: 34, weight: .black))
                                    .foregroundColor(.nexIndigo)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Split bills, not friendships.")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 40)
                            
                            // Start Split Flow Hero
                            Button {
                                appState.navigate(to: .selectPeople)
                            } label: {
                                AppCard(padding: 32, backgroundColor: .clear) {
                                    VStack(spacing: 24) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white.opacity(0.2))
                                                .frame(width: 80, height: 80)
                                            Image(systemName: "plus.viewfinder")
                                                .font(.system(size: 40, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        
                                        VStack(spacing: 8) {
                                            Text("Start New Split")
                                                .font(.system(size: 24, weight: .bold))
                                                .foregroundColor(.white)
                                            Text("Scan a receipt to begin")
                                                .font(.system(size: 16))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        
                                        HStack {
                                            Text("Launch Scanner")
                                                .fontWeight(.bold)
                                            Image(systemName: "chevron.right")
                                        }
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 14)
                                        .background(Color.white)
                                        .foregroundColor(.nexIndigo)
                                        .cornerRadius(16)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .background(Color.nexPrimaryGradient)
                                .cornerRadius(32)
                                .shadow(color: .nexIndigo.opacity(0.3), radius: 20, x: 0, y: 15)
                            }
                            .padding(.horizontal, 24)
                            .buttonStyle(.plain)
                            
                            // Total Spend Card
                            AppCard(padding: 24, backgroundColor: .nexSlate900) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Total Spend")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                        Text("₹\(String(format: "%.2f", appState.totalSpend))")
                                            .font(.system(size: 32, weight: .black))
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        Image(systemName: "indianrupeesign")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // Secondary Actions
                            HStack(spacing: 16) {
                                Button { appState.navigate(to: .groups) } label: {
                                    StatMiniCard(title: "My Groups", value: "\(appState.groups.count)", icon: "person.3.fill", color: .nexIndigo)
                                }
                                .buttonStyle(.plain)
                                
                                Button { appState.navigate(to: .bills) } label: {
                                    StatMiniCard(title: "History", value: "\(appState.bills.count)", icon: "clock.fill", color: .green)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 24)
                            
                            // Recent Bills (Only show if not empty)
                            if !appState.bills.isEmpty {
                                VStack(alignment: .leading, spacing: 20) {
                                    Text("Recent Splits")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.nexSlate900)
                                        .padding(.horizontal, 24)
                                    
                                    VStack(spacing: 16) {
                                        ForEach(appState.bills.prefix(3)) { bill in
                                            BillRow(bill: bill)
                                                .swipeActions(edge: .trailing) {
                                                    Button(role: .destructive) {
                                                        appState.deleteBill(bill)
                                                    } label: {
                                                        Label("Delete", systemImage: "trash")
                                                    }
                                                }
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }
                        }
                        .padding(.vertical)
                        .padding(.bottom, 120)
                    }
                }
                
                NexBottomNav(activeTab: .home)
            }
        }
    }
}

// MARK: - Bills View
struct BillsView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.nexSlate50.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 32) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("My Bills")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundColor(.nexSlate900)
                                Text("Your settlement history")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 40)
                            
                            VStack(spacing: 16) {
                                if appState.bills.isEmpty {
                                    VStack(spacing: 20) {
                                        Image(systemName: "doc.text.magnifyingglass")
                                            .font(.system(size: 60))
                                            .foregroundColor(.nexSlate200)
                                        Text("No bills found")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.top, 100)
                                } else {
                                    ForEach(appState.bills) { bill in
                                        BillRow(bill: bill)
                                            .swipeActions(edge: .trailing) {
                                                Button(role: .destructive) {
                                                    appState.deleteBill(bill)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 120)
                    }
                }
                
                NexBottomNav(activeTab: .bills)
            }
        }
    }
}

// MARK: - Shared Components
enum NexTab {
    case home, bills, groups
}

struct NexBottomNav: View {
    @Environment(AppState.self) private var appState
    let activeTab: NexTab
    
    var body: some View {
        HStack {
            Spacer()
            ToolbarIcon(icon: "house.fill", label: "Home", active: activeTab == .home)
                .onTapGesture { appState.navigate(to: .dashboard) }
            Spacer()
            ToolbarIcon(icon: "doc.text.fill", label: "Bills", active: activeTab == .bills)
                .onTapGesture { appState.navigate(to: .bills) }
            Spacer()
            ToolbarIcon(icon: "person.2.fill", label: "Groups", active: activeTab == .groups)
                .onTapGesture { appState.navigate(to: .groups) }
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.bottom, 34) // Area for home indicator
        .background(Color.white)
        .overlay(Rectangle().fill(Color.nexSlate200).frame(height: 0.5), alignment: .top)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
    }
}

struct ToolbarIcon: View {
    let icon: String
    let label: String
    let active: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                if active {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.nexIndigo.opacity(0.1))
                        .frame(width: 44, height: 32)
                }
                
                Image(systemName: active ? icon : icon.replacingOccurrences(of: ".fill", with: ""))
                    .font(.system(size: 20, weight: active ? .bold : .medium))
            }
            
            Text(label)
                .font(.system(size: 11, weight: active ? .black : .semibold))
        }
        .foregroundColor(active ? .nexIndigo : .nexSlate400)
        .frame(width: 65)
        .padding(.top, 4)
        .contentShape(Rectangle())
    }
}

struct BillRow: View {
    let bill: Bill
    
    var body: some View {
        NavigationLink(destination: BillDetailView(bill: bill)) {
            AppCard(padding: 16) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.nexIndigo.opacity(0.1))
                            .frame(width: 52, height: 52)
                        Image(systemName: "receipt")
                            .font(.system(size: 20))
                            .foregroundColor(.nexIndigo)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(bill.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.nexSlate900)
                        Text(bill.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("₹\(String(format: "%.2f", bill.total))")
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(.nexIndigo)
                        Text(bill.status.rawValue)
                            .font(.system(size: 9, weight: .black))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatMiniCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        AppCard(padding: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 14))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.nexSlate900)
                    Text(title)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Bill Detail View
struct BillDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.displayScale) var displayScale
    @Environment(\.dismiss) private var dismiss
    let bill: Bill
    
    var body: some View {
        ZStack {
            Color.nexSlate50.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        AppCard(padding: 24, backgroundColor: .nexIndigo) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Grand Total")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("₹\(String(format: "%.2f", bill.total))")
                                        .font(.system(size: 36, weight: .black))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                        }
                        .padding(.top, 20)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Settlement Breakdown")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.nexSlate900)
                            
                            VStack(spacing: 12) {
                                ForEach(bill.people) { person in
                                    HStack {
                                        NexAvatar(name: person.name, colorName: person.colorName, size: 40)
                                        VStack(alignment: .leading) {
                                            Text(person.name)
                                                .fontWeight(.medium)
                                            Text(person.id == appState.currentUser?.id ? "Paid By You" : "To be paid")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Text("₹\(String(format: "%.2f", calculateTotal(for: person)))")
                                            .fontWeight(.bold)
                                            .foregroundColor(.nexSlate900)
                                    }
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Line Items")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.nexSlate900)
                            
                            VStack(spacing: 1) {
                                ForEach(bill.items) { item in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name)
                                                .fontWeight(.medium)
                                            Text("Qty: \(item.quantity)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Text("₹\(String(format: "%.2f", item.price))")
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.vertical, 12)
                                    if item != bill.items.last { Divider() }
                                }
                            }
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }
                
                VStack {
                    if let uiImage = renderSummary() {
                        ShareLink(item: Image(uiImage: uiImage), preview: SharePreview("Bill Summary", image: Image(uiImage: uiImage))) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18, weight: .bold))
                                Text("Share Settlement Summary")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.nexIndigo)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        }
                    }
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(32, corners: [.topLeft, .topRight])
                .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: -10)
            }
        }
        .navigationTitle(bill.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    appState.deleteBill(bill)
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private func calculateTotal(for person: Person) -> Double {
        var total: Double = 0
        for item in bill.items {
            if item.assignedToPersonalIds.contains(person.id) {
                total += (item.price * Double(item.quantity)) / Double(item.assignedToPersonalIds.count)
            }
        }
        if bill.subtotal > 0 {
            let share = total / bill.subtotal
            total += (bill.tax * share) + (bill.serviceCharge * share)
        }
        return total
    }
    
    @MainActor
    private func renderSummary() -> UIImage? {
        let renderer = ImageRenderer(content: 
            SummaryView(
                title: bill.title,
                date: bill.date,
                items: bill.items,
                people: bill.people,
                subtotal: bill.subtotal,
                tax: bill.tax,
                serviceCharge: bill.serviceCharge,
                grandTotal: bill.total
            )
        )
        renderer.scale = displayScale
        return renderer.uiImage
    }
}
