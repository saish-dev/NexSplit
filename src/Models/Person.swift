import Foundation
import SwiftData

@Model
final class Person: Identifiable, Codable {
    @Attribute(.unique) var id: String
    var name: String
    var avatar: String?
    var colorName: String
    
    init(id: String = UUID().uuidString, name: String, avatar: String? = nil, colorName: String) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.colorName = colorName
    }
    
    // Codable support for JSON/NexSplit AI parsing if needed
    enum CodingKeys: String, CodingKey {
        case id, name, avatar, colorName
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
        colorName = try container.decode(String.self, forKey: .colorName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(avatar, forKey: .avatar)
        try container.encode(colorName, forKey: .colorName)
    }
}
