//
//  Product.swift
//  Store
//

struct Product: Decodable, Identifiable {
    public var id: Int
    public var title: String
    public var price: Int
    public var description: String
    public var category: Category
    public var images: [String]
    
    public init(id: Int, title: String, price: Int, description: String, category: Category, images: [String]) {
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.category = category
        self.images = images
    }
}
