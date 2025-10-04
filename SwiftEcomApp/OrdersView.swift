import SwiftUI

struct OrdersView: View {
    @StateObject private var viewModel = OrdersViewModel()
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading && viewModel.orders.isEmpty {
                    ProgressView("Loading orders...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.orders.isEmpty {
                    EmptyOrdersView()
                } else {
                    List {
                        ForEach(viewModel.orders) { order in
                            NavigationLink(destination: OrderDetailView(order: order)) {
                                OrderRowView(order: order)
                            }
                        }
                    }
                    .refreshable {
                        viewModel.loadOrders(userId: cartManager.cart.userId)
                    }
                }
            }
            .navigationTitle("Orders")
            .onAppear {
                viewModel.loadOrders(userId: cartManager.cart.userId)
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
    }
}

struct OrderRowView: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Order #\(order.id)")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(order.formattedTotal)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            HStack {
                Text("\(order.totalItems) item\(order.totalItems == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(order.formattedCreatedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Status:")
                    .font(.subheadline)
                
                Text(order.orderStatus.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(order.orderStatus.color))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(order.orderStatus.color).opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
            }
            
            Text("Payment: \(order.paymentMethod.replacingOccurrences(of: "_", with: " ").capitalized)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct EmptyOrdersView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("No orders yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Place your first order to see it here!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct OrderDetailView: View {
    let order: Order
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Order Summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("Order Summary")
                        .font(.headline)
                    
                    HStack {
                        Text("Order #:")
                            .fontWeight(.semibold)
                        Text("\(order.id)")
                        Spacer()
                    }
                    
                    HStack {
                        Text("Date:")
                            .fontWeight(.semibold)
                        Text(order.formattedCreatedDate)
                        Spacer()
                    }
                    
                    HStack {
                        Text("Status:")
                            .fontWeight(.semibold)
                        Text(order.orderStatus.displayName)
                            .foregroundColor(Color(order.orderStatus.color))
                        Spacer()
                    }
                    
                    HStack {
                        Text("Total:")
                            .fontWeight(.semibold)
                        Text(order.formattedTotal)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Order Items
                VStack(alignment: .leading, spacing: 8) {
                    Text("Order Items")
                        .font(.headline)
                    
                    ForEach(order.items) { item in
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: item.thumbnail)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 60, height: 60)
                            .cornerRadius(6)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .lineLimit(2)
                                
                                Text(item.brand)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Text("Qty: \(item.quantity)")
                                        .font(.caption)
                                    Spacer()
                                    Text(item.formattedTotalPrice)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Shipping Information
                VStack(alignment: .leading, spacing: 8) {
                    Text("Shipping Information")
                        .font(.headline)
                    
                    Text(order.shippingAddress)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Payment Information
                VStack(alignment: .leading, spacing: 8) {
                    Text("Payment Information")
                        .font(.headline)
                    
                    HStack {
                        Text("Method:")
                            .fontWeight(.semibold)
                        Text(order.paymentMethod.replacingOccurrences(of: "_", with: " ").capitalized)
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                if !order.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        
                        Text(order.notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    OrdersView()
        .environmentObject(CartManager())
}
