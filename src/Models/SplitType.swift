import Foundation

enum SplitType: String, Codable, CaseIterable {
    case equal = "EQUAL"
    case shares = "SHARES"
    case full = "FULL"
}
