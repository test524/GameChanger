//
//  File.swift
//  Networkmanager
//
//  Created by Pavan Kumar Reddy on 21/02/26.
//

import Foundation


// MARK: - Network Errors
public enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case noInternetConnection
    case timeout
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:              return "The request URL is invalid."
        case .invalidResponse:         return "Received an invalid response from the server."
        case .httpError(let code):     return "HTTP error with status code \(code)."
        case .decodingError(let e):    return "Failed to decode response: \(e.localizedDescription)"
        case .noInternetConnection:    return "No internet connection. Please check your network."
        case .timeout:                 return "The request timed out. Please try again."
        case .unknown(let e):          return "An unexpected error occurred: \(e.localizedDescription)"
        }
    }
}

// MARK: - HTTP Method
public enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
}

// MARK: - Endpoint Protocol
protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryParameters: [String: String] { get }
    var headers: [String: String] { get }
}

extension Endpoint {
    public func urlRequest() throws -> URLRequest {
        guard var components = URLComponents(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = queryParameters.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        guard let url = components.url else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url, timeoutInterval: 30)
        request.httpMethod = method.rawValue
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        return request
    }
}
