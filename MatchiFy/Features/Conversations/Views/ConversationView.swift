import SwiftUI
import Foundation

struct ConversationView: View {
    @StateObject private var viewModel: ConversationViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputFocused: Bool
    
    init(viewModel: ConversationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // Computed properties - use conversation data directly (same as ConversationRowView)
    private var otherUserName: String {
        guard let conversation = viewModel.conversation else {
            return ""
        }
        return conversation.getOtherUserName(isRecruiter: viewModel.isRecruiter)
    }
    
    private var otherUserImageURL: URL? {
        guard let conversation = viewModel.conversation else {
            return nil
        }
        return conversation.getOtherUserProfileImageURL(isRecruiter: viewModel.isRecruiter)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages, id: \.messageId) { message in
                            messageBubble(message: message)
                                .id(message.messageId)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(AppTheme.Colors.groupedBackground)
                .onChange(of: viewModel.messages.count) { oldCount, newCount in
                    if newCount > oldCount, let lastMessage = viewModel.messages.last {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.messageId, anchor: .bottom)
                            }
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.messageId, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            inputSection
        }
        .background(AppTheme.Colors.groupedBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadConversation()
            viewModel.loadMessages()
            // Mark conversation as read when opened
            viewModel.markAsRead()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.primary)
                        .frame(width: 36, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(AppTheme.Colors.secondaryBackground)
                        )
                }
                
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
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                // Name - use conversation data directly, no fallback placeholders
                Text(otherUserName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppTheme.Colors.groupedBackground)
            
            // Separator below header
            Rectangle()
                .fill(AppTheme.Colors.separator)
                .frame(height: 0.5)
        }
    }
    
    // MARK: - Message Bubble
    private func messageBubble(message: ConversationMessageModel) -> some View {
        HStack {
            if viewModel.isMessageFromCurrentUser(message) {
                Spacer()
            }
            
            VStack(alignment: viewModel.isMessageFromCurrentUser(message) ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 16))
                    .foregroundColor(viewModel.isMessageFromCurrentUser(message) ? .white : AppTheme.Colors.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(viewModel.isMessageFromCurrentUser(message) ? AppTheme.Colors.primary : AppTheme.Colors.secondaryBackground)
                    )
                    .overlay(
                        // Border for non-primary messages in light mode
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                viewModel.isMessageFromCurrentUser(message) ? Color.clear : AppTheme.Colors.messageBubbleBorder,
                                lineWidth: 0.5
                            )
                    )
                    .shadow(
                        color: viewModel.isMessageFromCurrentUser(message) ? Color.clear : AppTheme.Colors.cardShadow,
                        radius: 2,
                        x: 0,
                        y: 1
                    )
                
                Text(message.formattedTime)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: viewModel.isMessageFromCurrentUser(message) ? .trailing : .leading)
            
            if !viewModel.isMessageFromCurrentUser(message) {
                Spacer()
            }
        }
    }
    
    // MARK: - Input Section
    private var inputSection: some View {
        VStack(spacing: 0) {
            // Separator above input
            Rectangle()
                .fill(AppTheme.Colors.separator)
                .frame(height: 0.5)
            
            HStack(spacing: 12) {
                TextField("Type a message...", text: $viewModel.messageText, axis: .vertical)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppTheme.Colors.inputBorder, lineWidth: 0.5)
                    )
                    .focused($isInputFocused)
                    .lineLimit(1...4)
                
                Button {
                    viewModel.sendMessage()
                    isInputFocused = false
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppTheme.Colors.textSecondary.opacity(0.5) : AppTheme.Colors.primary)
                }
                .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSending)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppTheme.Colors.groupedBackground)
        }
    }
}

