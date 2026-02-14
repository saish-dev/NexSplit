import SwiftUI

struct GroupsView: View {
    @Environment(AppState.self) private var appState
    @State private var showingAddGroup = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.nexSlate50.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 32) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Groups")
                                        .font(.system(size: 34, weight: .bold))
                                        .foregroundColor(.nexSlate900)
                                    Text("Your splitting circles")
                                        .font(.system(size: 16))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button {
                                    showingAddGroup = true
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.nexPrimaryGradient)
                                            .frame(width: 48, height: 48)
                                        Image(systemName: "plus")
                                            .font(.title3.bold())
                                            .foregroundColor(.white)
                                    }
                                }
                                .shadow(color: .nexIndigo.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 40)
                            
                            if appState.groups.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "person.3.sequence.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.nexSlate200)
                                    Text("No groups yet")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    Text("Create a group to quickly select your friends for splitting bills.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                            } else {
                                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                                    ForEach(appState.groups) { group in
                                        NavigationLink(destination: GroupDetailView(group: group)) {
                                            AppCard(padding: 16) {
                                                VStack(alignment: .leading, spacing: 12) {
                                                    ZStack {
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .fill(Color.nexIndigo.opacity(0.1))
                                                            .frame(width: 44, height: 44)
                                                        Text(group.name.prefix(1))
                                                            .font(.title2)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.nexIndigo)
                                                    }
                                                    
                                                    VStack(alignment: .leading) {
                                                        Text(group.name)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.nexSlate900)
                                                        Text("\(group.members.count) members")
                                                            .font(.caption2)
                                                            .foregroundColor(.secondary)
                                                    }
                                                    
                                                    HStack(spacing: -8) {
                                                        ForEach(group.members.prefix(4)) { member in
                                                            NexAvatar(name: member.name, colorName: member.colorName, size: 24)
                                                        }
                                                    }
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                appState.deleteGroup(group)
                                            } label: {
                                                Label("Delete Group", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Friends List")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.nexSlate900)
                                    .padding(.horizontal, 24)
                                
                                VStack(spacing: 0) {
                                    if appState.friends.isEmpty {
                                        Text("Add friends to start splitting!")
                                            .foregroundColor(.secondary)
                                            .padding()
                                    } else {
                                        ForEach(appState.friends, id: \.id) { friend in
                                            HStack {
                                                NexAvatar(person: friend, size: 48)
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(friend.name)
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .foregroundColor(.nexSlate900)
                                                    Text("Friend")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.secondary)
                                                }
                                                Spacer()
                                                
                                                Button {
                                                    appState.deleteFriend(friend)
                                                } label: {
                                                    Image(systemName: "trash")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(.nexSlate400)
                                                        .frame(width: 32, height: 32)
                                                        .background(Color.nexSlate50)
                                                        .clipShape(Circle())
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 16)
                                            .contentShape(Rectangle())
                                            
                                            if friend != appState.friends.last {
                                                Divider().padding(.leading, 84)
                                            }
                                        }
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(24)
                                .shadow(color: .black.opacity(0.02), radius: 10, x: 0, y: 5)
                                .padding(.horizontal, 24)
                            }
                        }
                        .padding(.vertical)
                        .padding(.bottom, 120)
                    }
                }
                
                NexBottomNav(activeTab: .groups)
            }
            .onAppear {
                appState.loadData()
            }
            .background(Color.nexSlate50)
            .sheet(isPresented: $showingAddGroup) {
                CreateGroupSheet(isPresented: $showingAddGroup)
            }
        }
    }
}

struct CreateGroupSheet: View {
    @Environment(AppState.self) private var appState
    @Binding var isPresented: Bool
    @State private var groupName = ""
    @State private var selectedMembers: Set<String> = []
    @State private var newFriendName = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    Section {
                        TextField("Group Name", text: $groupName)
                            .font(.system(size: 16))
                    } header: {
                        Text("Group Details")
                    }
                    
                    Section {
                        HStack {
                            TextField("Friend's name", text: $newFriendName)
                            Button {
                                if let newFriend = appState.createFriend(name: newFriendName) {
                                    selectedMembers.insert(newFriend.id)
                                    newFriendName = ""
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.nexIndigo)
                                    .font(.title3)
                            }
                            .disabled(newFriendName.isEmpty)
                        }
                    } header: {
                        Text("Quick Add Friend")
                    }
                    
                    Section {
                        if appState.friends.isEmpty {
                            Text("No friends found.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(appState.friends) { friend in
                                Button {
                                    if selectedMembers.contains(friend.id) {
                                        selectedMembers.remove(friend.id)
                                    } else {
                                        selectedMembers.insert(friend.id)
                                    }
                                } label: {
                                    HStack {
                                        NexAvatar(person: friend, size: 32)
                                        Text(friend.name)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        if selectedMembers.contains(friend.id) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.nexIndigo)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(.nexSlate200)
                                        }
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Select Members")
                    }
                }
                
                VStack(spacing: 24) {
                    NexButton("Create Group", size: .lg) {
                        let members = appState.friends.filter { selectedMembers.contains($0.id) }
                        appState.createGroup(name: groupName, members: members)
                        isPresented = false
                    }
                    .disabled(groupName.isEmpty || selectedMembers.isEmpty)
                }
                .padding(24)
                .background(Color.white)
            }
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct GroupDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let group: NexGroup
    
    var body: some View {
        ZStack {
            Color.nexSlate50.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.nexPrimaryGradient)
                                .frame(width: 80, height: 80)
                            Text(group.name.prefix(1).uppercased())
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .shadow(color: .nexIndigo.opacity(0.3), radius: 10, y: 5)
                        
                        Text(group.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.nexSlate900)
                        
                        Text("\(group.members.count) members")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Members Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Members")
                            .font(.headline)
                            .foregroundColor(.nexSlate900)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            ForEach(group.members) { member in
                                HStack {
                                    NexAvatar(person: member, size: 40)
                                    Text(member.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.nexSlate900)
                                    Spacer()
                                }
                                .padding()
                                if member.id != group.members.last?.id {
                                    Divider()
                                        .padding(.leading, 72)
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    // Actions
                    Button(role: .destructive) {
                        appState.deleteGroup(group)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Group")
                        }
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
