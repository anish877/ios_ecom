import Foundation
import Combine

class CartManager: ObservableObject {
    @Published var cart: CartResponseData = CartResponseData(items: [], total: 0, totalItems: 0, userId: "user123")
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var totalItems: Int {
        cart.totalItems
    }
    
    var totalPrice: Double {
        cart.total
    }
    
    init(userId: String = "user123") {
        cart = CartResponseData(items: [], total: 0, totalItems: 0, userId: userId)
        loadCart()
    }
    
    func loadCart() {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchCart(userId: cart.userId)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    self?.cart = response.data
                }
            )
            .store(in: &cancellables)
    }
    
    func addToCart(product: Product, quantity: Int = 1) {
        isLoading = true
        errorMessage = nil
        
        networkService.addToCart(userId: cart.userId, productId: product.id, quantity: quantity)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    self?.cart = response.data
                }
            )
            .store(in: &cancellables)
    }
    
    func updateCartItem(productId: Int, quantity: Int) {
        isLoading = true
        errorMessage = nil
        
        networkService.updateCartItem(userId: cart.userId, productId: productId, quantity: quantity)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    self?.cart = response.data
                }
            )
            .store(in: &cancellables)
    }
    
    func removeFromCart(productId: Int) {
        isLoading = true
        errorMessage = nil
        
        networkService.removeFromCart(userId: cart.userId, productId: productId)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    self?.cart = response.data
                }
            )
            .store(in: &cancellables)
    }
    
    func clearCart() {
        isLoading = true
        errorMessage = nil
        
        networkService.clearCart(userId: cart.userId)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    self?.cart = response.data
                }
            )
            .store(in: &cancellables)
    }
    
    func getCartItemQuantity(for productId: Int) -> Int {
        return cart.items.first { $0.id == productId }?.quantity ?? 0
    }
    
    func isInCart(productId: Int) -> Bool {
        return cart.items.contains { $0.id == productId }
    }
}
