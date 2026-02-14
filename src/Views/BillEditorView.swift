import SwiftUI
import Charts

struct BillEditorView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.displayScale) var displayScale
    
    @State private var items: [BillItem] = []
    @State private var tax: Double = 0
    @State private var serviceCharge: Double = 0
    @State private var billTitle: String = ""
    
    var subtotal: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    var grandTotal: Double {
        subtotal + tax + serviceCharge
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.nexSlate50.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Summary Card
                    AppCard(padding: 24, backgroundColor: .nexIndigo) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Grand Total")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                Text("₹\(String(format: "%.2f", grandTotal))")
                                    .font(.system(size: 36, weight: .black))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 56, height: 56)
                                Image(systemName: "receipt")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .shadow(color: .nexIndigo.opacity(0.3), radius: 15, x: 0, y: 10)
                    
                    // Editor List
                    List {
                        Section {
                            TextField("Enter restaurant name...", text: $billTitle)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.nexSlate900)
                        } header: {
                            Text("Bill Details").font(.system(size: 13, weight: .bold)).kerning(1.2)
                        }
                        
                        Section {
                            ForEach($items) { $item in
                                ItemEditorRow(item: $item, people: appState.selectedPeople)
                                    .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                                    .listRowBackground(Color.white)
                            }
                            .onDelete { indexSet in
                                items.remove(atOffsets: indexSet)
                            }
                            
                            Button {
                                items.append(BillItem(name: "New Item", price: 0))
                            } label: {
                                Label("Add another item", systemImage: "plus.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.nexIndigo)
                            }
                            .padding(.vertical, 8)
                        } header: {
                            Text("Line Items").font(.system(size: 13, weight: .bold)).kerning(1.2)
                        }
                        
                        Section {
                            SummaryField(label: "Subtotal", value: subtotal, isEditable: false)
                            SummaryField(label: "Taxes & Fees", value: $tax, isEditable: true)
                            SummaryField(label: "Service Charge", value: $serviceCharge, isEditable: true)
                        } header: {
                            Text("Adjustments").font(.system(size: 13, weight: .bold)).kerning(1.2)
                        }
                        
                        Section {
                            VStack(spacing: 24) {
                                if subtotal > 0 {
                                    SummaryChartView(items: items, people: appState.selectedPeople, tax: tax, serviceCharge: serviceCharge)
                                        .frame(height: 180)
                                        .padding(.vertical, 10)
                                }
                                
                                VStack(spacing: 12) {
                                    ForEach(appState.selectedPeople) { person in
                                        PersonSplitRow(person: person, total: calculateTotal(for: person))
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        } header: {
                            Text("Settlement Breakdown").font(.system(size: 13, weight: .bold)).kerning(1.2)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    
                    VStack(spacing: 16) {
                        NexButton("Finalize & Save", size: .lg) {
                            appState.createBill(
                                title: billTitle,
                                items: items,
                                tax: tax,
                                serviceCharge: serviceCharge,
                                total: grandTotal
                            )
                            appState.navigate(to: .dashboard)
                        }
                        .shadow(color: .nexIndigo.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                    }
                    .padding(24)
                    .background(Color.white)
                    .glassmorphicBorder()
                    .cornerRadius(32, corners: [.topLeft, .topRight])
                    .shadow(color: .black.opacity(0.04), radius: 20, x: 0, y: -10)
                }
            }
            .navigationTitle("Review Settlement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        appState.navigate(to: .upload)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
            }
            .onAppear {
                self.items = appState.parsedItems
                self.tax = appState.taxAmount
                self.serviceCharge = appState.serviceChargeAmount
                self.billTitle = appState.extractedRestaurantName ?? "New Bill"
            }
        }
    }
    
    // Logic
    private func calculateTotal(for person: Person) -> Double {
        var total: Double = 0
        for item in items {
            if item.assignedToPersonalIds.contains(person.id) {
                total += (item.price * Double(item.quantity)) / Double(item.assignedToPersonalIds.count)
            }
        }
        
        // Add proportional tax and service charge
        if subtotal > 0 {
            let share = total / subtotal
            total += (tax * share) + (serviceCharge * share)
        }
        
        return total
    }
    
    @MainActor
    private func renderSummary() -> UIImage? {
        let renderer = ImageRenderer(content: 
            SummaryView(
                title: billTitle,
                date: Date(),
                items: items,
                people: appState.selectedPeople,
                subtotal: subtotal,
                tax: tax,
                serviceCharge: serviceCharge,
                grandTotal: grandTotal
            )
        )
        
        renderer.scale = displayScale
        return renderer.uiImage
    }
}

struct SummaryField: View {
    let label: String
    var value: Double?
    @Binding var bindingValue: Double
    let isEditable: Bool
    
    init(label: String, value: Double, isEditable: Bool) {
        self.label = label
        self.value = value
        self._bindingValue = .constant(0)
        self.isEditable = isEditable
    }
    
    init(label: String, value: Binding<Double>, isEditable: Bool) {
        self.label = label
        self._bindingValue = value
        self.value = nil
        self.isEditable = isEditable
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            Spacer()
            if isEditable {
                TextField("0.00", value: $bindingValue, format: .number)
                    .font(.system(size: 16, weight: .semibold))
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .foregroundColor(.nexSlate900)
            } else {
                Text("₹\(String(format: "%.2f", value ?? 0))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.nexSlate900)
            }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ItemEditorRow: View {
    @Binding var item: BillItem
    let people: [Person]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("Item name", text: $item.name)
                    .fontWeight(.medium)
                Spacer()
                TextField("0.00", value: $item.price, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            
            HStack {
                Stepper("Qty: \(item.quantity)", value: $item.quantity, in: 1...100)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if item.assignedToPersonalIds.isEmpty {
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.orange)
                            }
                            Text("Unassigned")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                        }
                    }
                    
                    ForEach(people) { person in
                        let isSelected = item.assignedToPersonalIds.contains(person.id)
                        Button {
                            toggleAssignment(for: person.id)
                        } label: {
                            VStack(spacing: 4) {
                                NexAvatar(name: person.name, colorName: person.colorName, size: 32)
                                    .opacity(isSelected ? 1 : 0.4)
                                    .overlay(
                                        Circle()
                                            .stroke(isSelected ? Color.nexIndigo : Color.clear, lineWidth: 2)
                                    )
                                
                                Text(person.name)
                                    .font(.caption2)
                                    .fontWeight(isSelected ? .bold : .regular)
                                    .foregroundColor(isSelected ? .nexIndigo : .secondary)
                                    .lineLimit(1)
                                    .frame(width: 60)
                            }
                            .scaleEffect(isSelected ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func toggleAssignment(for personId: String) {
        if item.assignedToPersonalIds.contains(personId) {
            item.assignedToPersonalIds.removeAll { $0 == personId }
        } else {
            item.assignedToPersonalIds.append(personId)
        }
    }
}

struct SummaryChartView: View {
    let items: [BillItem]
    let people: [Person]
    let tax: Double
    let serviceCharge: Double
    
    private var chartData: [(name: String, value: Double, color: Color)] {
        people.map { person in
            (person.name, calculateTotal(for: person), Color.fromTailwind(person.colorName))
        }
    }
    
    var body: some View {
        Chart(chartData, id: \.name) { data in
            SectorMark(
                angle: .value("Value", data.value),
                innerRadius: .ratio(0.6),
                angularInset: 2
            )
            .foregroundStyle(data.color)
            .cornerRadius(4)
        }
    }
    
    private func calculateTotal(for person: Person) -> Double {
        let subtotal = items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        var total: Double = 0
        for item in items {
            if item.assignedToPersonalIds.contains(person.id) {
                total += (item.price * Double(item.quantity)) / Double(item.assignedToPersonalIds.count)
            }
        }
        if subtotal > 0 {
            let share = total / subtotal
            total += (tax * share) + (serviceCharge * share)
        }
        return total
    }
}

struct PersonSplitRow: View {
    let person: Person
    let total: Double
    
    var body: some View {
        HStack {
            NexAvatar(name: person.name, colorName: person.colorName, size: 32)
            Text(person.name)
                .font(.subheadline)
            Spacer()
            Text("₹\(String(format: "%.2f", total))")
                .fontWeight(.bold)
        }
    }
}
