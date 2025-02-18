//
//  CacheManager.swift
//  Store
//

import Foundation

class CacheManager {
    let urlCache: URLCache
    
    init(
        memoryCapacity: Int = 50 * 1024 * 1024,
        diskCapacity: Int = 200 * 1024 * 1024
    ) {
        self.urlCache = URLCache(
            memoryCapacity: memoryCapacity,
            diskCapacity: diskCapacity,
            diskPath: "URLCache.shared.diskPath"
        )
    }
    
    func cacheResponse(_ data: Data, for url: URL) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
        let cachedResponse = CachedURLResponse(response: response, data: data)
        urlCache.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
    }
    
    func getCachedResponse(for url: URL) -> CachedURLResponse? {
        let request = URLRequest(url: url)
        return urlCache.cachedResponse(for: request)
    }
    
    func invalidateCache(for url: URL) {
        urlCache.removeCachedResponse(for: URLRequest(url: url))
    }
    
    func clearCache() {
        urlCache.removeAllCachedResponses()
    }
}
