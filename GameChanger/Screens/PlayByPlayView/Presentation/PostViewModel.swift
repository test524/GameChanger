//
//  PostViewModel.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 16/04/26.
//
import Combine
import Foundation

@Observable
class PostViewModel {

    var posts: [Post] = []
    var isLoading = false
    var errorMessage: String?

    private let useCase: GetPostsUseCase

    init(useCase: GetPostsUseCase) {
        self.useCase = useCase
    }

    func fetchPosts() {
        Task {
            isLoading = true
            do {
                posts = try await useCase.execute()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
}
