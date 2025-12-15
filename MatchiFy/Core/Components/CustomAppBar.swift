import SwiftUI

struct CustomAppBar: View {
    let title: String
    var onMenuTap: (() -> Void)? = nil
    var rightButton: (() -> AnyView)? = nil
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Menu Icon (Left)
            Button {
                onMenuTap?()
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(onMenuTap == nil)
            
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
            onMenuTap: { print("Menu tapped") }
        )
        Spacer()
    }
}
