//
//  PlayByPlayView.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 26/02/26.
//

import Foundation
import SwiftUI


struct PlayByPlayView: View {

    @State private var viewModel: PostViewModel

    init() {

        let api = APIService()
        let repo = PostRepositoryImpl(apiService: api)
        let useCase = GetPostsUseCase(repository: repo)

        _viewModel = State(initialValue: PostViewModel(useCase: useCase))
    }

    var body: some View {
        List(viewModel.posts) { post in
            VStack(alignment: .leading, spacing: 6) {
                Text(post.title)
                    .font(.headline)
                
                Text(post.body)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .listStyle(.plain)
        .task {
            print("Posts loading")
            viewModel.fetchPosts()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }
}

#Preview {
    PlayByPlayView()
}

