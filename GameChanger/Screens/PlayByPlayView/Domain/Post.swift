//
//  Post.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 16/04/26.
//


//MARK: - Domain
//MARK: Entity
struct Post: Decodable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

