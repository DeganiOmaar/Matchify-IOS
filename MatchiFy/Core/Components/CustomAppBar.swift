import SwiftUI

struct CustomAppBar: View {
    let title: String
    let profileImageURL: URL?
    var onProfileTap: (() -> Void)? = nil
    var rightButton: (() -> AnyView)? = nil
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Profile Image (Left)
            Button {
                onProfileTap?()
            } label: {
                Group {
                    if let url = profileImageURL {
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
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(onProfileTap == nil)
            
            // Centered Title
            Spacer()
            
            Text(title)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Spacer()
            
            // Right Button (Optional)
            if let rightButton = rightButton {
                rightButton()
            } else {
                // Placeholder to balance the layout
                Color.clear
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

// Preview
#Preview {
    VStack {
        CustomAppBar(
            title: "Messages",
            profileImageURL: nil
        )
        Spacer()
    }
}
