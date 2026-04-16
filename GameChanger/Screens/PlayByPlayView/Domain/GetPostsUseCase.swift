//
//  GetPostsUseCase.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 16/04/26.
//


//MARK: - Use case for get posts
class GetPostsUseCase {

    private let repository: GetPostsUseCaseProtocol

    init(repository: GetPostsUseCaseProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [Post] {
        return try await repository.getPosts()
    }
}