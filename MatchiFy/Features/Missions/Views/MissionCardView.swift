import SwiftUI

struct MissionCardView: View {
    let mission: MissionModel
    let isOwner: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onViewProposals: (() -> Void)?
    
    @State private var showMenu = false
    
    init(
        mission: MissionModel,
        isOwner: Bool,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        onViewProposals: (() -> Void)? = nil
    ) {
        self.mission = mission
        self.isOwner = isOwner
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onViewProposals = onViewProposals
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Header with Gradient Background
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(mission.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    // Three dots menu (only if owner)
                    if isOwner {
                        Button {
                            showMenu = true
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                )
                        }
                        .confirmationDialog("Actions", isPresented: $showMenu) {
                            if let onViewProposals = onViewProposals {
                                Button("Voir propositions") {
                                    onViewProposals()
                                }
                            }
                            Button("Edit Mission", role: .none) {
                                onEdit()
                            }
                            Button("Delete Mission", role: .destructive) {
                                onDelete()
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                }
                
                // MARK: - Description
                Text(mission.description)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.8),
                        Color.purple.opacity(0.7)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            // MARK: - Content Section
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Info Row (Duration & Budget)
                HStack(spacing: 24) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                        Text(mission.duration)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.black)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                        Text(mission.formattedBudget)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                }
                .padding(.top, 4)
                
                Divider()
                    .background(Color.gray.opacity(0.2))
                
                // MARK: - Skills Chips
                if !mission.skills.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Required Skills")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(mission.skills, id: \.self) { skill in
                                    Text(skill)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.blue.opacity(0.1))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                }
                
                // MARK: - Date Footer
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.6))
                    Text(mission.formattedDate)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray.opacity(0.7))
                    Spacer()
                }
                .padding(.top, 4)
            }
            .padding(20)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// Preview removed - all data is dynamic from backend

