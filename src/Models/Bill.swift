import Foundation
import SwiftData

@Model
final class Bill: Identifiable, Codable {
    @Attribute(.unique) var id: String
    var title: String
    var date: Date
    @Relationship(deleteRule: .cascade) var items: [BillItem]
    var subtotal: Double
    var tax: Double
    var serviceCharge: Double
    var total: Double
    var payerId: String
    var people: [Person]
    var statusValue: String
    
    var status: BillStatus {
        get { BillStatus(rawValue: statusValue) ?? .draft }
        set { statusValue = newValue.rawValue }
    }
    
    init(id: String = UUID().uuidString, title: String, date: Date = Date(), items: [BillItem] = [], subtotal: Double = 0, tax: Double = 0, serviceCharge: Double = 0, total: Double = 0, payerId: String = "", people: [Person] = [], status: BillStatus = .draft) {
        self.id = id
        self.title = title
        self.date = date
        self.items = items
        self.subtotal = subtotal
        self.tax = tax
        self.serviceCharge = serviceCharge
        self.total = total
        self.payerId = payerId
        self.people = people
        self.statusValue = status.rawValue
    }
    
    enum BillStatus: String, Codable {
        case draft = "DRAFT"
        case settled = "SETTLED"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, date, items, subtotal, tax, serviceCharge, total, payerId, people, statusValue
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        date = try container.decode(Date.self, forKey: .date)
        items = try container.decode([BillItem].self, forKey: .items)
        subtotal = try container.decode(Double.self, forKey: .subtotal)
        tax = try container.decode(Double.self, forKey: .tax)
        serviceCharge = try container.decode(Double.self, forKey: .serviceCharge)
        total = try container.decode(Double.self, forKey: .total)
        payerId = try container.decode(String.self, forKey: .payerId)
        people = try container.decode([Person].self, forKey: .people)
        statusValue = try container.decode(String.self, forKey: .statusValue)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(date, forKey: .date)
        try container.encode(items, forKey: .items)
        try container.encode(subtotal, forKey: .subtotal)
        try container.encode(tax, forKey: .tax)
        try container.encode(serviceCharge, forKey: .serviceCharge)
        try container.encode(total, forKey: .total)
        try container.encode(payerId, forKey: .payerId)
        try container.encode(people, forKey: .people)
        try container.encode(statusValue, forKey: .statusValue)
    }
}

@Model
final class NexGroup: Identifiable, Codable {
    @Attribute(.unique) var id: String
    var name: String
    var members: [Person]
    var totalBills: Int
    
    init(id: String = UUID().uuidString, name: String, members: [Person] = [], totalBills: Int = 0) {
        self.id = id
        self.name = name
        self.members = members
        self.totalBills = totalBills
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, members, totalBills
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        members = try container.decode([Person].self, forKey: .members)
        totalBills = try container.decode(Int.self, forKey: .totalBills)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(members, forKey: .members)
        try container.encode(totalBills, forKey: .totalBills)
    }
}
