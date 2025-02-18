//
//  MultipartFormData.swift
//  Store
//

import Foundation.NSData

struct File {
    let fieldName: String
    let fileName: String
    let mimeType: String
    let fileData: Data
}

// MultipartFormData structure for organizing form data and files
struct MultipartFormData {
    let fields: [String: String] // Regular form fields (key-value pairs)
    let files: [File] // File data
    
    init(fields: [String: String], files: [File]) {
        self.fields = fields
        self.files = files
    }
    
    // Example method for validation
    func validate() throws {
        if fields.isEmpty && files.isEmpty {
            throw NetworkError.invalidRequestBody
        }
    }
    
    func createBody(boundary: String) -> Data? {
        var body = Data()
        
        // Add form fields
        for (key, value) in fields {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        // Add files
        for file in files {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(file.fieldName)\"; filename=\"\(file.fileName)\"\r\n")
            body.append("Content-Type: \(file.mimeType)\r\n\r\n")
            body.append(file.fileData)
            body.append("\r\n")
        }
        
        // End of multipart form data
        body.append("--\(boundary)--\r\n")
        
        return body
    }
}

// Extension for Data to easily append strings
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
