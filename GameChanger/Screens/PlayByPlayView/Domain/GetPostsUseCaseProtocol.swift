//
//  GetPostsUseCaseProtocol.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 16/04/26.
//


//MARK: Repository
protocol GetPostsUseCaseProtocol {
    func getPosts() async throws -> [Post]
}