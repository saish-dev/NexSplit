import SwiftUI

struct SummaryView: View {
    let title: String
    let date: Date
    let items: [BillItem]
    let people: [Person]
    let subtotal: Double
    let tax: Double
    let serviceCharge: Double
    let grandTotal: Double
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.nexIndigo)
                        .frame(width: 56, height: 56)
                    Image(systemName: "receipt")
                        .foregroundColor(.white)
                        .font(.title2.bold())
                }
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.nexSlate900)
                    .multilineTextAlignment(.center)
                
                Text(date.formatted(date: .long, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Settlement Summary
            VStack(alignment: .leading, spacing: 16) {
                Text("Settlement")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.nexIndigo)
                
                VStack(spacing: 12) {
                    ForEach(people) { person in
                        HStack {
                            NexAvatar(name: person.name, colorName: person.colorName, size: 32)
                            Text(person.name)
                                .font(.system(size: 16, weight: .medium))
                            Spacer()
                            Text("₹\(String(format: "%.2f", calculateTotal(for: person)))")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.nexSlate900)
                        }
                    }
                }
            }
            
            Divider()
            
            // Line Items Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Line Items")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.nexIndigo)
                
                VStack(spacing: 10) {
                    ForEach(items) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.nexSlate900)
                                if item.assignedToPersonalIds.count > 0 {
                                    Text("Shared by \(item.assignedToPersonalIds.count)")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Text("₹\(String(format: "%.2f", item.price * Double(item.quantity)))")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.nexSlate900)
                        }
                    }
                }
            }
            
            Divider()
            
            // Grand Total
            VStack(spacing: 8) {
                SummaryRow(label: "Subtotal", value: subtotal)
                if tax > 0 { SummaryRow(label: "Tax", value: tax) }
                if serviceCharge > 0 { SummaryRow(label: "Service Charge", value: serviceCharge) }
                
                HStack {
                    Text("Grand Total")
                        .font(.system(size: 18, weight: .black))
                    Spacer()
                    Text("₹\(String(format: "%.2f", grandTotal))")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.nexIndigo)
                }
                .padding(.top, 8)
            }
            
            Spacer(minLength: 20)
            
            VStack(spacing: 4) {
                Text("Split with NexBill")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.nexIndigo)
                Text("Smooth splits, happy friendships.")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding(40)
        .frame(width: 450)
        .background(Color.white)
    }
    
    private func calculateTotal(for person: Person) -> Double {
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

struct SummaryRow: View {
    let label: String
    let value: Double
    var isBold: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(isBold ? .primary : .secondary)
            Spacer()
            Text("₹\(String(format: "%.2f", value))")
                .fontWeight(isBold ? .bold : .regular)
                .foregroundColor(isBold ? .nexIndigo : .primary)
        }
        .font(isBold ? .headline : .subheadline)
    }
}
