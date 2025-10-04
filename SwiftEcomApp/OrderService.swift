import Foundation
import Combine

class OrderService: ObservableObject {
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    func createOrder(
        userId: String,
        shippingAddress: String,
        paymentMethod: String,
        notes: String?,
        completion: @escaping (Result<Order, Error>) -> Void
    ) {
        networkService.createOrder(
            userId: userId,
            shippingAddress: shippingAddress,
            paymentMethod: paymentMethod,
            notes: notes ?? ""
        )
        .sink(
            receiveCompletion: { result in
                if case .failure(let error) = result {
                    completion(.failure(error))
                }
            },
            receiveValue: { response in
                completion(.success(response.data))
            }
        )
        .store(in: &cancellables)
    }
    
    func fetchOrders(userId: String) -> AnyPublisher<[Order], Error> {
        return networkService.fetchOrders(userId: userId)
            .map { $0.data }
            .eraseToAnyPublisher()
    }
    
    func fetchOrder(userId: String, orderId: Int) -> AnyPublisher<Order, Error> {
        return networkService.fetchOrder(userId: userId, orderId: orderId)
            .map { $0.data }
            .eraseToAnyPublisher()
    }
}
