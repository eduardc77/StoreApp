//
//  Category.swift
//  Store
//

struct Category: Decodable, Identifiable {
    public var id: Int
    public var name: String
    public var image: String
    
    public init(id: Int, name: String, image: String) {
        self.id = id
        self.name = name
        self.image = image
    }
}
