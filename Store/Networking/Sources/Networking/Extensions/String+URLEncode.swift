//
//  String+URLEncode.swift
//  Store
//

extension String {

    func formEncoded() -> String? {
        self.urlEncoded()?
            .replacingOccurrences(of: "+", with: "%2B")
    }

    func urlEncoded() -> String? {
        self.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)?
            .replacingOccurrences(of: "&", with: "%26")
    }
}
