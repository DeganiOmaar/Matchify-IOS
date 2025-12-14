import SwiftUI

struct MyOffersView: View {
    @StateObject private var viewModel = MyOffersViewModel()
    @State private var selectedOffer: OfferModel?
    @State private var offerToEdit: OfferModel?
    @State private var offerToDelete: OfferModel?
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Offers List
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredOffers.isEmpty {
                    emptyState
                } else {
                    offersList
                }
            }
            .background(Color.black)
            .navigationTitle("My Offers")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refresh()
            }
            .onAppear {
                viewModel.loadMyOffers()
            }
            .sheet(item: $selectedOffer) { offer in
                OfferDetailsView(offer: offer)
            }
            .sheet(item: $offerToEdit) { offer in
                EditOfferView(offer: offer, onOfferUpdated: {
                    viewModel.loadMyOffers()
                })
            }
            .alert("Delete Offer", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    offerToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let offer = offerToDelete {
                        viewModel.deleteOffer(offer)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this offer? This action cannot be undone.")
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            TextField("Search my offers...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
            
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppTheme.Colors.groupedBackground)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var offersList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredOffers) { offer in
                    OfferRowView(
                        offer: offer,
                        onTap: {
                            selectedOffer = offer
                        },
                        onEdit: {
                            offerToEdit = offer
                        },
                        onDelete: {
                            offerToDelete = offer
                            showDeleteConfirmation = true
                        }
                    )
                }
            }
            .padding(16)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text(viewModel.searchText.isEmpty ? "No Offers Yet" : "No Offers Found")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text(viewModel.searchText.isEmpty ? "Create your first offer to get started" : "Try adjusting your search")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}

// MARK: - Offer Row View
struct OfferRowView: View {
    let offer: OfferModel
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
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
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                .clipped()
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .lineLimit(2)
                    
                    Text(offer.formattedPrice)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                    
                    Text(offer.category)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 8) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.Colors.primary)
                            .frame(width: 32, height: 32)
                            .background(AppTheme.Colors.primary.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                            .frame(width: 32, height: 32)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
