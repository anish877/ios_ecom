import SwiftUI

struct ContentView: View {
    @StateObject private var cartManager = CartManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ProductListView()
                .environmentObject(cartManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Products")
                }
                .tag(0)
            
            CartView()
                .environmentObject(cartManager)
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Cart")
                    if cartManager.totalItems > 0 {
                        Text("\(cartManager.totalItems)")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 10, y: -10)
                    }
                }
                .tag(1)
            
            OrdersView()
                .environmentObject(cartManager)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Orders")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}
