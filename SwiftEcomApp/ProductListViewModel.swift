import Foundation
import Combine

class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var categories: [String] = []
    @Published var isLoading = false
    @Published var hasMoreProducts = true
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedCategory: String?
    
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private var currentSkip = 0
    private let limit = 20
    
    func loadProducts() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        if selectedCategory != nil {
            loadProductsByCategory()
        } else {
            loadAllProducts()
        }
    }
    
    private func loadAllProducts() {
        networkService.fetchProducts(limit: limit, skip: currentSkip)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    if self?.currentSkip == 0 {
                        self?.products = response.data.products
                    } else {
                        self?.products.append(contentsOf: response.data.products)
                    }
                    self?.hasMoreProducts = response.data.products.count == self?.limit
                    self?.currentSkip += response.data.products.count
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadProductsByCategory() {
        guard let category = selectedCategory else { return }
        
        networkService.fetchProductsByCategory(category: category, limit: limit, skip: currentSkip)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    if self?.currentSkip == 0 {
                        self?.products = response.data.products
                    } else {
                        self?.products.append(contentsOf: response.data.products)
                    }
                    self?.hasMoreProducts = response.data.products.count == self?.limit
                    self?.currentSkip += response.data.products.count
                }
            )
            .store(in: &cancellables)
    }
    
    func loadMoreProducts() {
        guard hasMoreProducts && !isLoading else { return }
        loadProducts()
    }
    
    func refreshProducts() {
        currentSkip = 0
        hasMoreProducts = true
        loadProducts()
    }
    
    func searchProducts() {
        guard !searchText.isEmpty else {
            refreshProducts()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        networkService.searchProducts(query: searchText)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    self?.products = response.data.products
                    self?.hasMoreProducts = false
                }
            )
            .store(in: &cancellables)
    }
    
    func loadCategories() {
        networkService.fetchCategories()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    self?.categories = response.data
                }
            )
            .store(in: &cancellables)
    }
}
