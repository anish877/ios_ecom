# Swift E-Commerce iOS App

A SwiftUI iOS application that connects to the Express.js backend for a complete e-commerce experience.

## Features

- **Product Catalog**: Browse products with search and category filtering
- **Shopping Cart**: Add, update, and remove items from cart
- **Order Management**: Create orders and track order history
- **Modern UI**: Beautiful SwiftUI interface with responsive design
- **Real-time Updates**: Live cart updates and order tracking

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Backend server running on `http://localhost:3000`

## Project Structure

```
SwiftEcomApp/
├── SwiftEcomAppApp.swift          # Main app entry point
├── ContentView.swift              # Main tab view container
├── Models.swift                   # Data models (Product, Cart, Order)
├── NetworkService.swift           # API communication service
├── CartManager.swift              # Cart state management
├── ProductListView.swift          # Product listing and search
├── ProductListViewModel.swift     # Product list business logic
├── ProductDetailView.swift        # Product detail screen
├── CartView.swift                 # Shopping cart screen
├── CheckoutView.swift             # Order checkout screen
├── OrderService.swift             # Order management service
├── OrdersView.swift               # Order history screen
└── OrdersViewModel.swift          # Order list business logic
```

## Getting Started

### 1. Start the Backend Server

Make sure the backend server is running:

```bash
cd ../backend
npm start
```

The server should be running on `http://localhost:3000`

### 2. Open the iOS Project

1. Open `SwiftEcomApp.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the project (⌘+R)

### 3. Using the App

1. **Products Tab**: Browse products, search, and filter by category
2. **Cart Tab**: View cart items, update quantities, and proceed to checkout
3. **Orders Tab**: View order history and order details

## API Integration

The app connects to the following backend endpoints:

- `GET /api/products` - Fetch products
- `GET /api/products/search/:query` - Search products
- `GET /api/products/categories` - Get categories
- `GET /api/cart/:userId` - Get user cart
- `POST /api/cart/:userId/add` - Add item to cart
- `PUT /api/cart/:userId/update` - Update cart item
- `DELETE /api/cart/:userId/remove/:productId` - Remove from cart
- `POST /api/orders/:userId/create` - Create order
- `GET /api/orders/:userId` - Get user orders

## Architecture

### MVVM Pattern
- **Models**: Data structures matching backend API
- **Views**: SwiftUI views for UI presentation
- **ViewModels**: Business logic and state management

### Key Components

1. **NetworkService**: Handles all API communications using Combine
2. **CartManager**: Manages cart state across the app
3. **AsyncImage**: Loads product images asynchronously
4. **Combine Publishers**: Reactive data flow for API responses

## Features in Detail

### Product Catalog
- Infinite scroll loading
- Search functionality
- Category filtering
- Product detail view with image carousel
- Add to cart with quantity selection

### Shopping Cart
- Real-time cart updates
- Quantity adjustment
- Remove items
- Cart total calculation
- Empty cart state

### Order Management
- Checkout form with shipping address
- Payment method selection
- Order confirmation
- Order history view
- Order status tracking

## Customization

### Backend URL
To change the backend URL, update the `baseURL` in `NetworkService.swift`:

```swift
private let baseURL = "http://your-backend-url:port"
```

### User ID
The app uses a fixed user ID (`user123`). To implement user authentication, modify the `CartManager` to use dynamic user IDs.

### Styling
The app uses SwiftUI's built-in styling with custom button styles and color schemes. Modify the button styles in the respective view files to customize the appearance.

## Troubleshooting

### Common Issues

1. **Backend Connection Failed**
   - Ensure backend server is running on `http://localhost:3000`
   - Check network connectivity
   - Verify CORS settings in backend

2. **Images Not Loading**
   - Check internet connection
   - Verify image URLs in backend response
   - Ensure proper AsyncImage implementation

3. **Cart Not Updating**
   - Check backend API responses
   - Verify CartManager state updates
   - Ensure proper Combine publishers

### Debug Tips

- Use Xcode's network inspector to monitor API calls
- Check console logs for error messages
- Verify backend health endpoint: `http://localhost:3000/health`

## Future Enhancements

- User authentication and registration
- Push notifications for order updates
- Offline support with Core Data
- Payment integration (Apple Pay, Stripe)
- Product reviews and ratings
- Wishlist functionality
- Social sharing features

## License

MIT License - see LICENSE file for details.
