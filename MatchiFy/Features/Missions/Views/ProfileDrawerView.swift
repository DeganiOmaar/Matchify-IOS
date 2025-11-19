import SwiftUI

/// Left-side drawer view for profile (content will be added later)
struct ProfileDrawerView: View {
    @ObservedObject var viewModel: MissionListViewModel
    
    init(viewModel: MissionListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Profile")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Button {
                    withAnimation {
                        viewModel.showProfileDrawer = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(8)
                }
            }
            .padding(20)
            .background(AppTheme.Colors.cardBackground)
            
            // Empty content for now
            VStack {
                Spacer()
                Text("Drawer Content")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Colors.groupedBackground)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(AppTheme.Colors.groupedBackground)
    }
}

