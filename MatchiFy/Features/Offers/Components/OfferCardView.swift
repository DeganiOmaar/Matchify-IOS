import SwiftUI

struct OfferCardView: View {
    let offer: OfferModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Banner Image
            AsyncImage(url: URL(string: "\(Endpoints.baseURL)/\(offer.bannerImage)")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    Rectangle()
                        .fill(AppTheme.Colors.groupedBackground)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        )
                @unknown default:
                    Rectangle()
                        .fill(AppTheme.Colors.groupedBackground)
                }
            }
            .frame(height: 120)
            .clipped()
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(offer.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(2)
                
                Text(offer.formattedPrice)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primary)
                
                // Category Badge
                HStack {
                    Image(systemName: OfferCategory(rawValue: offer.category)?.iconName ?? "tag")
                        .font(.system(size: 10))
                    Text(offer.category)
                        .font(.system(size: 11))
                }
                .foregroundColor(AppTheme.Colors.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.Colors.groupedBackground)
                .cornerRadius(8)
            }
            .padding(12)
        }
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}
