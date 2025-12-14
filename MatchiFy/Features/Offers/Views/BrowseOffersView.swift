import SwiftUI

struct BrowseOffersView: View {
    @StateObject private var viewModel = BrowseOffersViewModel()
    @State private var selectedOffer: OfferModel?
    @State private var showFilters = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and Filter Bar
                searchFilterBar
                
                // Category Filter Pills
                if viewModel.selectedCategory != nil || !viewModel.searchText.isEmpty {
                    activeFiltersBar
                }
                
                // Offers Grid
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredOffers.isEmpty {
                    emptyState
                } else {
                    offersGrid
                }
            }
            .background(Color.black)
            .navigationTitle("Browse Offers")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(item: $selectedOffer) { offer in
                OfferDetailsView(offer: offer)
            }
            .sheet(isPresented: $showFilters) {
                FilterSheet(viewModel: viewModel)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
    }
    
    private var searchFilterBar: some View {
        HStack(spacing: 12) {
            // Search Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                TextField("Search offers...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        viewModel.applyFilters()
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                        viewModel.applyFilters()
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
            
            // Filter Button
            Button {
                showFilters = true
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.Colors.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black)
    }
    
    private var activeFiltersBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let category = viewModel.selectedCategory {
                    FilterChip(text: category.displayName) {
                        viewModel.selectedCategory = nil
                        viewModel.applyFilters()
                    }
                }
                
                if !viewModel.searchText.isEmpty {
                    FilterChip(text: "Search: \(viewModel.searchText)") {
                        viewModel.searchText = ""
                        viewModel.applyFilters()
                    }
                }
                
                Button {
                    viewModel.clearFilters()
                } label: {
                    Text("Clear All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color.black)
    }
    
    private var offersGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(viewModel.filteredOffers) { offer in
                    OfferCardView(offer: offer)
                        .onTapGesture {
                            selectedOffer = offer
                        }
                }
            }
            .padding(16)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text("No Offers Found")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("Try adjusting your filters or check back later")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}

struct FilterChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.system(size: 14))
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AppTheme.Colors.primary.opacity(0.1))
        .foregroundColor(AppTheme.Colors.primary)
        .cornerRadius(16)
    }
}

struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: BrowseOffersViewModel
    @State private var tempCategory: OfferCategory?
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Filter by Category")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(OfferCategory.allCases, id: \.self) { category in
                            Button {
                                tempCategory = tempCategory == category ? nil : category
                            } label: {
                                HStack {
                                    Image(systemName: category.iconName)
                                        .frame(width: 24)
                                    
                                    Text(category.displayName)
                                        .font(.system(size: 16))
                                    
                                    Spacer()
                                    
                                    if tempCategory == category {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(AppTheme.Colors.primary)
                                    }
                                }
                                .foregroundColor(AppTheme.Colors.textPrimary)
                                .padding()
                                .background(AppTheme.Colors.groupedBackground)
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Apply Button
                Button {
                    viewModel.selectedCategory = tempCategory
                    viewModel.applyFilters()
                    dismiss()
                } label: {
                    Text("Apply Filters")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                tempCategory = viewModel.selectedCategory
            }
        }
    }
}
