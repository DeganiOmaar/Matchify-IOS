import SwiftUI

struct CategorySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: OfferCategory?
    @State private var navigateToCreateOffer = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Category Grid
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Select a Category")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .padding(.top, 32)
                        
                        Text("Choose the category that best describes your service offering")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(OfferCategory.allCases, id: \.self) { category in
                                CategoryCard(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                    }
                }
                
                // Continue Button
                if selectedCategory != nil {
                    Button {
                        navigateToCreateOffer = true
                    } label: {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .background(AppTheme.Colors.background)
            .navigationDestination(isPresented: $navigateToCreateOffer) {
                if let category = selectedCategory {
                    CreateOfferView(category: category)
                }
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(width: 32, height: 32)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(AppTheme.Colors.groupedBackground)
    }
}

struct CategoryCard: View {
    let category: OfferCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                Image(systemName: category.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.primary)
                
                Text(category.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.groupedBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.border, lineWidth: isSelected ? 0 : 1)
            )
            .shadow(color: isSelected ? AppTheme.Colors.primary.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
