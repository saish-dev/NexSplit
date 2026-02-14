import Foundation
import SwiftData

@Model
final class BillItem: Identifiable, Codable {
    @Attribute(.unique) var id: String
    var name: String
    var price: Double
    var quantity: Int
    var assignedToPersonalIds: [String]
    
    init(id: String = UUID().uuidString, name: String, price: Double, quantity: Int = 1, assignedTo: [String] = []) {
        self.id = id
        self.name = name
        self.price = price
        self.quantity = quantity
        self.assignedToPersonalIds = assignedTo
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, price, quantity, assignedToPersonalIds
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(Double.self, forKey: .price)
        quantity = try container.decode(Int.self, forKey: .quantity)
        assignedToPersonalIds = try container.decode([String].self, forKey: .assignedToPersonalIds)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(price, forKey: .price)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(assignedToPersonalIds, forKey: .assignedToPersonalIds)
    }
}
