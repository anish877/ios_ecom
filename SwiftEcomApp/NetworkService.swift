import Foundation
import Combine

class NetworkService: ObservableObject {
    static let shared = NetworkService()
    
    private let baseURL = "http://10.7.31.248:3000"
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Generic Request Method
    private func request<T: Codable>(_ endpoint: String, method: HTTPMethod = .GET, body: Data? = nil) -> AnyPublisher<T, Error> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: APIError(message: "Invalid URL", statusCode: nil))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Product Endpoints
    func fetchProducts(limit: Int = 20, skip: Int = 0) -> AnyPublisher<ProductsResponse, Error> {
        let endpoint = "/api/products?limit=\(limit)&skip=\(skip)"
        return request(endpoint)
    }
    
    func fetchProduct(id: Int) -> AnyPublisher<SingleProductResponse, Error> {
        let endpoint = "/api/products/\(id)"
        return request(endpoint)
    }
    
    func searchProducts(query: String, limit: Int = 20, skip: Int = 0) -> AnyPublisher<ProductsResponse, Error> {
        let endpoint = "/api/products/search/\(query)?limit=\(limit)&skip=\(skip)"
        return request(endpoint)
    }
    
    func fetchCategories() -> AnyPublisher<CategoriesResponse, Error> {
        let endpoint = "/api/products/categories"
        return request(endpoint)
    }
    
    func fetchProductsByCategory(category: String, limit: Int = 20, skip: Int = 0) -> AnyPublisher<ProductsResponse, Error> {
        let endpoint = "/api/products/category/\(category)?limit=\(limit)&skip=\(skip)"
        return request(endpoint)
    }
    
    // MARK: - Cart Endpoints
    func fetchCart(userId: String) -> AnyPublisher<CartResponse, Error> {
        let endpoint = "/api/cart/\(userId)"
        return request(endpoint)
    }
    
    func addToCart(userId: String, productId: Int, quantity: Int = 1) -> AnyPublisher<CartResponse, Error> {
        let endpoint = "/api/cart/\(userId)/add"
        let body = AddToCartRequest(productId: productId, quantity: quantity)
        
        do {
            let data = try JSONEncoder().encode(body)
            return request(endpoint, method: .POST, body: data)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func updateCartItem(userId: String, productId: Int, quantity: Int) -> AnyPublisher<CartResponse, Error> {
        let endpoint = "/api/cart/\(userId)/update"
        let body = UpdateCartRequest(productId: productId, quantity: quantity)
        
        do {
            let data = try JSONEncoder().encode(body)
            return request(endpoint, method: .PUT, body: data)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func removeFromCart(userId: String, productId: Int) -> AnyPublisher<CartResponse, Error> {
        let endpoint = "/api/cart/\(userId)/remove/\(productId)"
        return request(endpoint, method: .DELETE)
    }
    
    func clearCart(userId: String) -> AnyPublisher<CartResponse, Error> {
        let endpoint = "/api/cart/\(userId)/clear"
        return request(endpoint, method: .DELETE)
    }
    
    // MARK: - Order Endpoints
    func createOrder(userId: String, shippingAddress: String, paymentMethod: String, notes: String = "") -> AnyPublisher<OrderResponse, Error> {
        let endpoint = "/api/orders/\(userId)/create"
        let body = CreateOrderRequest(shippingAddress: shippingAddress, paymentMethod: paymentMethod, notes: notes)
        
        do {
            let data = try JSONEncoder().encode(body)
            return request(endpoint, method: .POST, body: data)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func fetchOrders(userId: String) -> AnyPublisher<OrdersResponse, Error> {
        let endpoint = "/api/orders/\(userId)"
        return request(endpoint)
    }
    
    func fetchOrder(userId: String, orderId: Int) -> AnyPublisher<OrderResponse, Error> {
        let endpoint = "/api/orders/\(userId)/\(orderId)"
        return request(endpoint)
    }
    
    // MARK: - Health Check
    func healthCheck() -> AnyPublisher<HealthResponse, Error> {
        let endpoint = "/health"
        return request(endpoint)
    }
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - Request Models
struct AddToCartRequest: Codable {
    let productId: Int
    let quantity: Int
}

struct UpdateCartRequest: Codable {
    let productId: Int
    let quantity: Int
}

struct CreateOrderRequest: Codable {
    let shippingAddress: String
    let paymentMethod: String
    let notes: String
}

struct HealthResponse: Codable {
    let status: String
    let timestamp: String
}
