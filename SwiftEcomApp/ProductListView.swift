import SwiftUI

struct ProductListView: View {
    @StateObject private var viewModel = ProductListViewModel()
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading && viewModel.products.isEmpty {
                    ProgressView("Loading products...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.products) { product in
                            NavigationLink(destination: ProductDetailView(product: product)) {
                                ProductRowView(product: product)
                                    .environmentObject(cartManager)
                            }
                        }
                        
                        if viewModel.hasMoreProducts {
                            HStack {
                                Spacer()
                                if viewModel.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Button("Load More") {
                                        viewModel.loadMoreProducts()
                                    }
                                    .foregroundColor(.blue)
                                }
                                Spacer()
                            }
                            .padding()
                            .onAppear {
                                viewModel.loadMoreProducts()
                            }
                        }
                    }
                    .refreshable {
                        viewModel.refreshProducts()
                    }
                }
            }
            .navigationTitle("Products")
            .searchable(text: $viewModel.searchText, prompt: "Search products")
            .onSubmit(of: .search) {
                viewModel.searchProducts()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("All Categories") {
                            viewModel.selectedCategory = nil
                            viewModel.refreshProducts()
                        }
                        
                        ForEach(viewModel.categories, id: \.self) { category in
                            Button(category.capitalized) {
                                viewModel.selectedCategory = category
                                viewModel.refreshProducts()
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .onAppear {
            viewModel.loadProducts()
            viewModel.loadCategories()
        }
    }
}

struct ProductRowView: View {
    let product: Product
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: product.thumbnail)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
            }
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(product.brand ?? "Unknown Brand")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    if let discountPercentage = product.discountPercentage, discountPercentage > 0 {
                        Text(product.formattedPrice)
                            .font(.caption)
                            .strikethrough()
                            .foregroundColor(.secondary)
                        
                        Text(product.formattedDiscountedPrice)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    } else {
                        Text(product.formattedPrice)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(String(format: "%.1f", product.rating ?? 0.0))
                            .font(.caption)
                    }
                }
                
                HStack {
                    Text("Stock: \(product.stock ?? 0)")
                        .font(.caption)
                        .foregroundColor((product.stock ?? 0) > 0 ? .green : .red)
                    
                    Spacer()
                    
                    if cartManager.isInCart(productId: product.id) {
                        let quantity = cartManager.getCartItemQuantity(for: product.id)
                        HStack(spacing: 8) {
                            Button("-") {
                                if quantity > 1 {
                                    cartManager.updateCartItem(productId: product.id, quantity: quantity - 1)
                                } else {
                                    cartManager.removeFromCart(productId: product.id)
                                }
                            }
                            .buttonStyle(CartButtonStyle())
                            
                            Text("\(quantity)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(minWidth: 20)
                            
                            Button("+") {
                                cartManager.updateCartItem(productId: product.id, quantity: quantity + 1)
                            }
                            .buttonStyle(CartButtonStyle())
                        }
                    } else {
                        Button("Add to Cart") {
                            cartManager.addToCart(product: product)
                        }
                        .buttonStyle(CartButtonStyle())
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(6)
                        .font(.caption)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct CartButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ProductListView()
        .environmentObject(CartManager())
}
