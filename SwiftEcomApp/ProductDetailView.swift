import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var cartManager: CartManager
    @State private var selectedImageIndex = 0
    @State private var quantity = 1
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image Carousel
                TabView(selection: $selectedImageIndex) {
                    ForEach(0..<(product.images?.count ?? 0), id: \.self) { index in
                        AsyncImage(url: URL(string: product.images?[index] ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    ProgressView()
                                        .scaleEffect(1.5)
                                )
                        }
                        .tag(index)
                    }
                }
                .frame(height: 300)
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                VStack(alignment: .leading, spacing: 12) {
                    // Product Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(product.brand ?? "Unknown Brand")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            if let discountPercentage = product.discountPercentage, discountPercentage > 0 {
                                Text(product.formattedPrice)
                                    .font(.title3)
                                    .strikethrough()
                                    .foregroundColor(.secondary)
                                
                                Text(product.formattedDiscountedPrice)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                
                                Text("-\(Int(product.discountPercentage ?? 0))%")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.red)
                                    .cornerRadius(4)
                            } else {
                                Text(product.formattedPrice)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", product.rating ?? 0.0))
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        Text("Stock: \(product.stock ?? 0)")
                            .font(.subheadline)
                            .foregroundColor((product.stock ?? 0) > 0 ? .green : .red)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        
                        Text(product.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Category and Brand
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Details")
                            .font(.headline)
                        
                        HStack {
                            Text("Category:")
                                .fontWeight(.semibold)
                            Text(product.category.capitalized)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Brand:")
                                .fontWeight(.semibold)
                            Text(product.brand ?? "Unknown Brand")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 100) // Space for fixed button
            }
        }
        .navigationTitle(product.title)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            // Add to Cart Section
            VStack(spacing: 12) {
                if cartManager.isInCart(productId: product.id) {
                    let currentQuantity = cartManager.getCartItemQuantity(for: product.id)
                    
                    VStack(spacing: 8) {
                        Text("In Cart: \(currentQuantity) item\(currentQuantity == 1 ? "" : "s")")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        HStack(spacing: 16) {
                            Button("Remove") {
                                cartManager.removeFromCart(productId: product.id)
                            }
                            .buttonStyle(SecondaryButtonStyle())
                            
                            Button("Update") {
                                cartManager.updateCartItem(productId: product.id, quantity: quantity)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(quantity == currentQuantity)
                        }
                        
                        Stepper("Quantity: \(quantity)", value: $quantity, in: 1...10)
                            .padding(.horizontal)
                    }
                } else {
                    VStack(spacing: 12) {
                        HStack {
                            Stepper("Quantity: \(quantity)", value: $quantity, in: 1...10)
                                .frame(maxWidth: .infinity)
                            
                            Button("Add to Cart") {
                                cartManager.addToCart(product: product, quantity: quantity)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled((product.stock ?? 0) == 0)
                        }
                        
                        if (product.stock ?? 0) == 0 {
                            Text("Out of Stock")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    NavigationView {
        ProductDetailView(product: Product(
            id: 1,
            title: "iPhone 9",
            description: "An apple mobile which is nothing like apple",
            price: 549,
            discountPercentage: 12.96,
            rating: 4.69,
            stock: 94,
            brand: "Apple",
            category: "smartphones",
            thumbnail: "https://i.dummyjson.com/data/products/1/thumbnail.jpg",
            images: [
                "https://i.dummyjson.com/data/products/1/1.jpg",
                "https://i.dummyjson.com/data/products/1/2.jpg",
                "https://i.dummyjson.com/data/products/1/3.jpg"
            ],
            tags: ["smartphone", "apple"],
            sku: "IPH-001",
            weight: 194,
            dimensions: ProductDimensions(width: 15.0, height: 7.0, depth: 0.8),
            warrantyInformation: "1 year warranty",
            shippingInformation: "Ships in 1-2 business days",
            availabilityStatus: "In Stock",
            reviews: [
                ProductReview(rating: 5, comment: "Great phone!", date: "2025-01-01T00:00:00.000Z", reviewerName: "John Doe", reviewerEmail: "john@example.com")
            ],
            returnPolicy: "30 days return policy",
            minimumOrderQuantity: 1,
            meta: ProductMeta(createdAt: "2025-01-01T00:00:00.000Z", updatedAt: "2025-01-01T00:00:00.000Z", barcode: "123456789", qrCode: "https://example.com/qr.png")
        ))
    }
    .environmentObject(CartManager())
}
