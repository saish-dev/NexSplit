import SwiftUI

struct SelectPeopleView: View {
    @Environment(AppState.self) private var appState
    @State private var customName: String = ""
    @State private var selectedPeople: Set<String> = []
    
    var body: some View {
        ZStack {
            Color.nexSlate50.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Select People")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.nexSlate900)
                        Text("Who's splitting the bill today?")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button {
                        appState.navigate(to: .dashboard)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.nexSlate200)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        // Quick Select Group
                        if !appState.groups.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("QUICK GROUPS")
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundColor(.secondary)
                                    .kerning(1.2)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(appState.groups) { group in
                                            GroupCard(group: group) {
                                                selectGroup(group)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Friends
                        VStack(alignment: .leading, spacing: 16) {
                            Text("FRIENDS & CONTACTS")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.secondary)
                                .kerning(1.2)
                            
                            let allAvailable = (appState.currentUser != nil ? [appState.currentUser!] : []) + appState.friends
                            
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                                ForEach(allAvailable) { person in
                                    PersonTile(person: person, isSelected: selectedPeople.contains(person.id)) {
                                        togglePerson(person)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Add Custom
                        VStack(alignment: .leading, spacing: 16) {
                            Text("ADD NEW PERSON")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.secondary)
                                .kerning(1.2)
                            
                            HStack(spacing: 12) {
                                TextField("Enter their name...", text: $customName)
                                    .font(.system(size: 16))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.nexSlate200, lineWidth: 1)
                                    )
                                
                                Button {
                                    addCustomPerson()
                                } label: {
                                    ZStack {
                                        Group {
                                            if customName.isEmpty {
                                                RoundedRectangle(cornerRadius: 12).fill(Color.nexSlate200)
                                            } else {
                                                RoundedRectangle(cornerRadius: 12).fill(Color.nexPrimaryGradient)
                                            }
                                        }
                                            .frame(width: 48, height: 48)
                                        Image(systemName: "plus")
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                    }
                                }
                                .disabled(customName.isEmpty)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 120)
                }
                
                // Bottom Sticky Action
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(selectedPeople.count) Selected")
                                .font(.system(size: 14, weight: .bold))
                            Text("Min. 2 people required")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: -12) {
                                ForEach(getSelectedPeople()) { person in
                                    NexAvatar(name: person.name, colorName: person.colorName, size: 36)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                    
                    NexButton("Next: Upload Receipt", icon: "chevron.right", size: .lg) {
                        appState.selectedPeople = getSelectedPeople()
                        appState.navigate(to: .upload)
                    }
                    .disabled(selectedPeople.count < 2)
                    .shadow(color: selectedPeople.count < 2 ? .clear : .nexIndigo.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(24)
                .background(Color.white)
                .glassmorphicBorder()
                .cornerRadius(32, corners: [.topLeft, .topRight])
                .shadow(color: .black.opacity(0.04), radius: 20, x: 0, y: -10)
            }
        }
        .animation(.spring(), value: selectedPeople)
        .onAppear {
            if let user = appState.currentUser {
                selectedPeople.insert(user.id)
            }
        }
    }
    
    // Logic
    private func togglePerson(_ person: Person) {
        if selectedPeople.contains(person.id) {
            if person.id == appState.currentUser?.id { return } // Can't remove self
            selectedPeople.remove(person.id)
        } else {
            selectedPeople.insert(person.id)
        }
    }
    
    private func selectGroup(_ group: NexGroup) {
        for member in group.members {
            selectedPeople.insert(member.id)
        }
    }
    
    private func addCustomPerson() {
        guard !customName.isEmpty else { return }
        appState.createFriend(name: customName)
        customName = ""
    }
    
    private func getSelectedPeople() -> [Person] {
        let allAvailable = (appState.currentUser != nil ? [appState.currentUser!] : []) + appState.friends
        return allAvailable.filter { selectedPeople.contains($0.id) }
    }
}

struct GroupCard: View {
    let group: NexGroup
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            AppCard(padding: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(group.name)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(group.members.count)")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .background(Color.nexIndigo.opacity(0.1))
                            .foregroundColor(.nexIndigo)
                            .cornerRadius(4)
                    }
                    
                    HStack(spacing: -8) {
                        ForEach(group.members.prefix(4)) { member in
                            NexAvatar(name: member.name, colorName: member.colorName, size: 24)
                        }
                    }
                }
                .frame(width: 140)
            }
        }
    }
}

struct PersonTile: View {
    @Environment(AppState.self) private var appState
    let person: Person
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                ZStack(alignment: .bottomTrailing) {
                    NexAvatar(name: person.name, colorName: person.colorName, size: 44)
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.nexIndigo)
                            .background(Color.white)
                            .clipShape(Circle())
                            .offset(x: 4, y: 4)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(person.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    if person.id == appState.currentUser?.id {
                        Text("You")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
            .padding(8)
            .background(isSelected ? Color.nexIndigo.opacity(0.05) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.nexIndigo : Color.clear, lineWidth: 1)
            )
        }
    }
}
