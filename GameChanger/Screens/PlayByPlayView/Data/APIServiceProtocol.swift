//
//  APIServiceProtocol.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 16/04/26.
//
import Foundation

//MARK: - Data
protocol APIServiceProtocol {
    func fetchPosts() async throws -> [Post]
}

class APIService: APIServiceProtocol {

    func fetchPosts() async throws -> [Post] {
        let apiManager = NetworkManager()
        let endPoint = GetPostsEndPoint()
        let postsList: [Post] = try await apiManager.request(endPoint)
        return postsList
    }
}

struct GetPostsEndPoint : Endpoint {
    var baseURL: String {
        String("https://jsonplaceholder.typicode.com")
    }
    
    var path: String {
        String("/posts")
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var queryParameters: [String : String] {
        [:]
    }
    
    var headers: [String : String] {
        ["Content-Type":"application/json"]
    }
}
