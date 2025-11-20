import SwiftUI

struct ConversationRowView: View {
    let conversation: ConversationModel
    let isRecruiter: Bool
    let onTap: () -> Void
    
    // Computed properties - use conversation data directly
    private var otherUserName: String {
        conversation.getOtherUserName(isRecruiter: isRecruiter)
    }
    
    private var otherUserImageURL: URL? {
        conversation.getOtherUserProfileImageURL(isRecruiter: isRecruiter)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Profile Picture
                Group {
                    if let url = otherUserImageURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img):
                                img
                                    .resizable()
                                    .scaledToFill()
                            case .failure, .empty:
                                Image("avatar")
                                    .resizable()
                                    .scaledToFill()
                            @unknown default:
                                Image("avatar")
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                    } else {
                        Image("avatar")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    // Name - use conversation data directly, no fallback placeholders
                    Text(otherUserName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .lineLimit(1)
                    
                    // Last Message Preview
                    if let lastMessage = conversation.lastMessageText, !lastMessage.isEmpty {
                        Text(lastMessage)
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .lineLimit(1)
                    } else {
                        Text("No messages yet")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.6))
                            .italic()
                    }
                }
                
                Spacer()
                
                // Time
                if !conversation.formattedLastMessageTime.isEmpty {
                    Text(conversation.formattedLastMessageTime)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppTheme.Colors.groupedBackground)
        }
        .buttonStyle(.plain)
    }
}

