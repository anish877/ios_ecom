import Foundation
import Combine

class OrdersViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let orderService = OrderService()
    private var cancellables = Set<AnyCancellable>()
    
    func loadOrders(userId: String) {
        isLoading = true
        errorMessage = nil
        
        orderService.fetchOrders(userId: userId)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] orders in
                    self?.orders = orders
                }
            )
            .store(in: &cancellables)
    }
}
