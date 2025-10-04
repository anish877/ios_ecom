import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var showingCheckout = false
    
    var body: some View {
        NavigationView {
            VStack {
                if cartManager.cart.items.isEmpty {
                    EmptyCartView()
                } else {
                    List {
                        ForEach(cartManager.cart.items) { item in
                            CartItemRowView(item: item)
                                .environmentObject(cartManager)
                        }
                        .onDelete(perform: deleteItems)
                        
                        // Cart Summary
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Total Items:")
                                    .font(.headline)
                                Spacer()
                                Text("\(cartManager.cart.totalItems)")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            HStack {
                                Text("Total Price:")
                                    .font(.headline)
                                Spacer()
                                Text(cartManager.cart.formattedTotal)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .refreshable {
                        cartManager.loadCart()
                    }
                }
            }
            .navigationTitle("Cart")
            .toolbar {
                if !cartManager.cart.items.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear All") {
                            cartManager.clearCart()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !cartManager.cart.items.isEmpty {
                    VStack(spacing: 12) {
                        Button("Proceed to Checkout") {
                            showingCheckout = true
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        Text("Total: \(cartManager.cart.formattedTotal)")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
                }
            }
            .sheet(isPresented: $showingCheckout) {
                CheckoutView()
                    .environmentObject(cartManager)
            }
            .alert("Error", isPresented: .constant(cartManager.errorMessage != nil)) {
                Button("OK") {
                    cartManager.errorMessage = nil
                }
            } message: {
                if let errorMessage = cartManager.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            let item = cartManager.cart.items[index]
            cartManager.removeFromCart(productId: item.id)
        }
    }
}

struct CartItemRowView: View {
    let item: CartItem
    @EnvironmentObject var cartManager: CartManager
    @State private var quantity: Int
    
    init(item: CartItem) {
        self.item = item
        self._quantity = State(initialValue: item.quantity)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: item.thumbnail)) { image in
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
                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(item.brand)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(item.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(item.formattedTotalPrice)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            
            VStack(spacing: 8) {
                // Quantity Controls
                HStack(spacing: 8) {
                    Button("-") {
                        if quantity > 1 {
                            quantity -= 1
                            cartManager.updateCartItem(productId: item.id, quantity: quantity)
                        } else {
                            cartManager.removeFromCart(productId: item.id)
                        }
                    }
                    .buttonStyle(QuantityButtonStyle())
                    .disabled(cartManager.isLoading)
                    
                    Text("\(quantity)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(minWidth: 30)
                    
                    Button("+") {
                        quantity += 1
                        cartManager.updateCartItem(productId: item.id, quantity: quantity)
                    }
                    .buttonStyle(QuantityButtonStyle())
                    .disabled(cartManager.isLoading)
                }
                
                Button("Remove") {
                    cartManager.removeFromCart(productId: item.id)
                }
                .font(.caption)
                .foregroundColor(.red)
                .disabled(cartManager.isLoading)
            }
        }
        .padding(.vertical, 4)
        .onChange(of: item.quantity) { newValue in
            quantity = newValue
        }
    }
}

struct QuantityButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.blue)
            .frame(width: 30, height: 30)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(15)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct EmptyCartView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("Your cart is empty")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add some products to get started!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CartView()
        .environmentObject(CartManager())
}
