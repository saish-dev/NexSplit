import SwiftUI
import Observation
import SwiftData

enum AppScreen: Hashable {
    case dashboard
    case selectPeople
    case upload
    case editor
    case groups
    case bills
}

@Observable
class AppState {
    var path = NavigationPath()
    var currentScreen: AppScreen = .dashboard
    private var dataLoaded = false
    
    // Auth & User (Mock for local)
    var currentUser: Person?
    
    // Bill Data
    var selectedPeople: [Person] = []
    var parsedItems: [BillItem] = []
    var taxAmount: Double = 0
    var serviceChargeAmount: Double = 0
    var billImage: UIImage?
    var extractedRestaurantName: String?
    
    // Persistence Data (Reactive via SwiftData or manual fetch)
    var friends: [Person] = []
    var groups: [NexGroup] = []
    var bills: [Bill] = []
    
    // App Settings
    var isDarkMode: Bool = false
    
    private let geminiService = GeminiService(apiKey: Secrets.apiKey)
    var modelContext: ModelContext?
    
    func navigate(to screen: AppScreen) {
        currentScreen = screen
    }
    
    var totalSpend: Double {
        guard let userId = currentUser?.id else { return 0 }
        
        return bills.reduce(0) { total, bill in
            var userShare: Double = 0
            
            // Calculate item share
            for item in bill.items {
                if item.assignedToPersonalIds.contains(userId) {
                    let splitCount = Double(item.assignedToPersonalIds.count)
                    if splitCount > 0 {
                        userShare += (item.price * Double(item.quantity)) / splitCount
                    }
                }
            }
            
            // Add tax and service charge share
            if bill.subtotal > 0 {
                let shareRatio = userShare / bill.subtotal
                userShare += (bill.tax * shareRatio) + (bill.serviceCharge * shareRatio)
            }
            
            return total + userShare
        }
    }
    
    @MainActor
    func loadData() {
        guard let context = modelContext, !dataLoaded else { return }
        
        do {
            let friendDescriptor = FetchDescriptor<Person>(sortBy: [SortDescriptor(\.name)])
            let allPeople = try context.fetch(friendDescriptor)
            
            // Identify or create current user
            if let me = allPeople.first(where: { $0.id == "local_me" }) {
                self.currentUser = me
            } else {
                let me = Person(id: "local_me", name: "Saish (You)", colorName: "indigo-500")
                context.insert(me)
                self.currentUser = me
            }
            
            // Friends are everyone EXCEPT current user
            let loadedFriends = allPeople.filter { $0.id != "local_me" }
            
            // Fix existing friends with default grey color
            let vibrantColors = ["indigo-500", "purple-500", "emerald-500", "teal-500", "pink-500", "blue-500", "orange-500"]
            for friend in loadedFriends {
                if friend.colorName == "slate-500" {
                    friend.colorName = vibrantColors.randomElement() ?? "indigo-500"
                }
            }
            self.friends = loadedFriends
            
            let groupDescriptor = FetchDescriptor<NexGroup>(sortBy: [SortDescriptor(\.name)])
            self.groups = try context.fetch(groupDescriptor)
            
            let billDescriptor = FetchDescriptor<Bill>(sortBy: [SortDescriptor(\.date, order: .reverse)])
            self.bills = try context.fetch(billDescriptor)
            
            dataLoaded = true
        } catch {
            print("Error fetching SwiftData: \(error)")
        }
    }
    
    func parseSelectedImage() async throws {
        guard let image = billImage else { return }
        
        let result = try await geminiService.parseReceipt(image: image)
        
        self.parsedItems = result.items.map { raw in
            // Default to empty assignments to allow per-item selection
            BillItem(name: raw.name, price: raw.price, quantity: raw.quantity, assignedTo: [])
        }
        self.taxAmount = result.totalTax
        self.serviceChargeAmount = result.totalServiceCharge
        self.extractedRestaurantName = result.restaurantName
    }
    
    // MARK: - Persistence Actions
    @MainActor
    func createBill(title: String, items: [BillItem], tax: Double, serviceCharge: Double, total: Double) {
        guard let context = modelContext, let userId = currentUser?.id else { return }
        
        let newBill = Bill(
            id: UUID().uuidString,
            title: title.isEmpty ? "Untitled Bill" : title,
            date: Date(),
            items: items,
            subtotal: total - tax - serviceCharge,
            tax: tax,
            serviceCharge: serviceCharge,
            total: total,
            payerId: userId,
            people: selectedPeople,
            status: .settled
        )
        
        context.insert(newBill)
        self.bills.insert(newBill, at: 0)
        
        do {
            try context.save()
        } catch {
            print("Failed to save bill: \(error)")
        }
    }
    
    @MainActor
    @discardableResult
    func createFriend(name: String) -> Person? {
        guard let context = modelContext else { return nil }
        let colors = ["indigo-500", "purple-500", "emerald-500", "teal-500", "pink-500", "blue-500", "orange-500"]
        let randomColor = colors.randomElement() ?? "indigo-500"
        let newFriend = Person(id: UUID().uuidString, name: name, colorName: randomColor)
        context.insert(newFriend)
        self.friends.append(newFriend)
        
        do {
            try context.save()
            return newFriend
        } catch {
            print("Failed to save friend: \(error)")
            return nil
        }
    }
    
    @MainActor
    func createGroup(name: String, members: [Person]) {
        guard let context = modelContext else { return }
        let newGroup = NexGroup(id: UUID().uuidString, name: name, members: members, totalBills: 0)
        context.insert(newGroup)
        self.groups.append(newGroup)
        
        do {
            try context.save()
        } catch {
            print("Failed to save group: \(error)")
        }
    }
    
    @MainActor
    func deleteBill(_ bill: Bill) {
        guard let context = modelContext else { return }
        context.delete(bill)
        self.bills.removeAll { $0.id == bill.id }
        
        do {
            try context.save()
        } catch {
            print("Failed to delete bill: \(error)")
        }
    }
    
    @MainActor
    func deleteGroup(_ group: NexGroup) {
        guard let context = modelContext else { return }
        context.delete(group)
        self.groups.removeAll { $0.id == group.id }
        
        do {
            try context.save()
        } catch {
            print("Failed to delete group: \(error)")
        }
    }
    
    @MainActor
    func deleteFriend(_ friend: Person) {
        guard let context = modelContext else { return }
        context.delete(friend)
        self.friends.removeAll { $0.id == friend.id }
        
        do {
            try context.save()
        } catch {
            print("Failed to delete friend: \(error)")
        }
    }
    
    func resetBill() {
        if let user = currentUser {
            selectedPeople = [user]
        } else {
            selectedPeople = []
        }
        parsedItems = []
        taxAmount = 0
        serviceChargeAmount = 0
        billImage = nil
    }
}
