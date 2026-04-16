//
//  PostRepositoryImpl.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 16/04/26.
//
import Foundation

class PostRepositoryImpl: GetPostsUseCaseProtocol {

    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    func getPosts() async throws -> [Post] {
        return try await apiService.fetchPosts()
    }
}
