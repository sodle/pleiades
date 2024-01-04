//
//  Client.swift
//  Pleiades
//
//  Created by Scott Odle on 1/1/24.
//

import Foundation

public protocol FormDataEncodable {
    func formParameters() -> [URLQueryItem]
}

public func encodeFormData(_ data: FormDataEncodable) -> Data {
    var url = URL(string: "https://example.com")!
    url.append(queryItems: data.formParameters())
    return url.query(percentEncoded: true)!.data(using: .utf8)!
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

public struct Request<Response> {
    var method: HTTPMethod
    var url: URL
    var query: [String: String]?
    var body: Encodable?
    var form: FormDataEncodable?
}

public actor Client {
    let session: URLSession
    let baseURL: URL
    let deviceID: String
    
    public init(baseURL: URL,
                configuration: URLSessionConfiguration = .default,
                deviceID: String) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: configuration)
        self.deviceID = deviceID
        
        self.loadCookie()
    }
    
    func send<T: Decodable>(_ request: Request<T>) async throws -> T {
        var url = request.url
        if let query = request.query {
            for (key, value) in query {
                url.append(queryItems: [URLQueryItem(name: key, value: value)])
            }
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        if let body = request.body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
        } else if let form = request.form {
            urlRequest.httpBody = encodeFormData(form)
        }
        
        let (data, _) = try await session.data(for: urlRequest)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
