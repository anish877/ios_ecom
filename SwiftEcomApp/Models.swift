import Foundation

// MARK: - Product Models
struct Product: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let discountPercentage: Double?
    let rating: Double?
    let stock: Int?
    let brand: String?
    let category: String
    let thumbnail: String
    let images: [String]?
    let tags: [String]?
    let sku: String?
    let weight: Int?
    let dimensions: ProductDimensions?
    let warrantyInformation: String?
    let shippingInformation: String?
    let availabilityStatus: String?
    let reviews: [ProductReview]?
    let returnPolicy: String?
    let minimumOrderQuantity: Int?
    let meta: ProductMeta?
    
    var discountedPrice: Double {
        guard let discountPercentage = discountPercentage else { return price }
        return price * (1 - discountPercentage / 100)
    }
    
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
    
    var formattedDiscountedPrice: String {
        return String(format: "$%.2f", discountedPrice)
    }
}

struct ProductDimensions: Codable {
    let width: Double
    let height: Double
    let depth: Double
}

struct ProductReview: Codable {
    let rating: Int
    let comment: String
    let date: String
    let reviewerName: String
    let reviewerEmail: String
}

struct ProductMeta: Codable {
    let createdAt: String
    let updatedAt: String
    let barcode: String
    let qrCode: String
}

// Single product response
struct SingleProductResponse: Codable {
    let success: Bool
    let data: Product
}

// Multiple products response
struct ProductsResponse: Codable {
    let success: Bool
    let data: ProductData
}

struct ProductData: Codable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
}

// MARK: - Cart Models
struct CartItem: Codable, Identifiable {
    let id: Int
    let title: String
    let price: Double
    let thumbnail: String
    var quantity: Int
    let category: String
    let brand: String
    
    var totalPrice: Double {
        return price * Double(quantity)
    }
    
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
    
    var formattedTotalPrice: String {
        return String(format: "$%.2f", totalPrice)
    }
}

struct Cart: Codable {
    let items: [CartItem]
    let total: Double
    let totalItems: Int
    let userId: String
    
    var formattedTotal: String {
        return String(format: "$%.2f", total)
    }
}

struct CartResponseData: Codable {
    let items: [CartItem]
    let total: Double
    let totalItems: Int
    let userId: String
    
    var formattedTotal: String {
        return String(format: "$%.2f", total)
    }
}

struct CartResponse: Codable {
    let success: Bool
    let message: String?
    let data: CartResponseData
}

// MARK: - Order Models
struct Order: Codable, Identifiable {
    let id: Int
    let userId: String
    let items: [CartItem]
    let total: Double
    let totalItems: Int
    let shippingAddress: String
    let paymentMethod: String
    let notes: String
    let status: String  // Backend returns string, we'll convert to enum in UI
    let createdAt: String
    let updatedAt: String
    
    var formattedTotal: String {
        return String(format: "$%.2f", total)
    }
    
    var orderStatus: OrderStatus {
        return OrderStatus(rawValue: status) ?? .pending
    }
    
    var formattedCreatedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        if let date = formatter.date(from: createdAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return createdAt
    }
}

enum OrderStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case processing = "processing"
    case shipped = "shipped"
    case delivered = "delivered"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending:
            return "Pending"
        case .processing:
            return "Processing"
        case .shipped:
            return "Shipped"
        case .delivered:
            return "Delivered"
        case .cancelled:
            return "Cancelled"
        }
    }
    
    var color: String {
        switch self {
        case .pending:
            return "orange"
        case .processing:
            return "blue"
        case .shipped:
            return "purple"
        case .delivered:
            return "green"
        case .cancelled:
            return "red"
        }
    }
}

struct OrderResponse: Codable {
    let success: Bool
    let message: String?
    let data: Order
}

struct OrdersResponse: Codable {
    let success: Bool
    let data: [Order]
}

// MARK: - API Response Models
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let message: String?
    let data: T?
    let errors: [ValidationError]?
}

struct ValidationError: Codable {
    let msg: String
    let param: String
    let location: String
}

// MARK: - Category Models
struct CategoriesResponse: Codable {
    let success: Bool
    let data: [String]
}

// MARK: - Error Models
struct APIError: Error, LocalizedError {
    let message: String
    let statusCode: Int?
    
    var errorDescription: String? {
        return message
    }
}
