import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var shippingAddress = ""
    @State private var paymentMethod = "credit_card"
    @State private var notes = ""
    @State private var isCreatingOrder = false
    @State private var showingSuccessAlert = false
    @State private var errorMessage: String?
    
    private let paymentMethods = [
        ("credit_card", "Credit Card"),
        ("debit_card", "Debit Card"),
        ("paypal", "PayPal"),
        ("apple_pay", "Apple Pay"),
        ("cash_on_delivery", "Cash on Delivery")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                // Order Summary Section
                Section("Order Summary") {
                    ForEach(cartManager.cart.items) { item in
                        HStack {
                            AsyncImage(url: URL(string: item.thumbnail)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 50, height: 50)
                            .cornerRadius(6)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                
                                Text("Qty: \(item.quantity)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(item.formattedTotalPrice)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    HStack {
                        Text("Total:")
                            .font(.headline)
                        Spacer()
                        Text(cartManager.cart.formattedTotal)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                
                // Shipping Information Section
                Section("Shipping Information") {
                    TextField("Enter your shipping address", text: $shippingAddress, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Payment Method Section
                Section("Payment Method") {
                    Picker("Payment Method", selection: $paymentMethod) {
                        ForEach(paymentMethods, id: \.0) { method in
                            Text(method.1).tag(method.0)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Additional Notes Section
                Section("Additional Notes (Optional)") {
                    TextField("Any special instructions...", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Place Order") {
                        createOrder()
                    }
                    .disabled(shippingAddress.isEmpty || isCreatingOrder)
                    .fontWeight(.semibold)
                }
            }
            .alert("Order Placed!", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your order has been placed successfully!")
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
            .overlay {
                if isCreatingOrder {
                    ProgressView("Creating order...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                        .ignoresSafeArea()
                }
            }
        }
    }
    
    private func createOrder() {
        guard !shippingAddress.isEmpty else { return }
        
        isCreatingOrder = true
        errorMessage = nil
        
        let orderService = OrderService()
        orderService.createOrder(
            userId: cartManager.cart.userId,
            shippingAddress: shippingAddress,
            paymentMethod: paymentMethod,
            notes: notes.isEmpty ? nil : notes
        ) { [weak cartManager] result in
            DispatchQueue.main.async {
                isCreatingOrder = false
                
                switch result {
                case .success(let order):
                    // Clear cart after successful order
                    cartManager?.clearCart()
                    showingSuccessAlert = true
                    
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    CheckoutView()
        .environmentObject(CartManager())
}
