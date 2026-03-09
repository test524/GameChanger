//
//  SOLID.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 08/03/26.
//

import Foundation

//Single


//Open–Closed Principle.
//Software entities (classes, modules, functions) should be open for extension but closed for modification.
protocol GameAction {
    func perform()
}

struct HitAction: GameAction {
    func perform() {
        print("Handle hit")
    }
}

struct WalkAction: GameAction {
    func perform() {
        print("Handle walk")
    }
}

func performAction(_ action: GameAction) {
    action.perform()
}


//Liskov Substitution Principle
//Objects of a superclass should be replaceable with objects of a subclass without breaking the program.
//If a function expects a base type (protocol/class), you should be able to pass any subclass or conforming type without changing behavior.
protocol APIServiceProtocol {
    func fetchData() -> Data
}

class APIService: APIServiceProtocol {
    func fetchData() -> Data {
        Data()
    }
}

class MockAPIService: APIServiceProtocol {
    func fetchData() -> Data {
        Data("Mock".utf8)
    }
}

class ViewModel {
    let service: APIServiceProtocol
    
    init(service: APIServiceProtocol) {
        self.service = service
    }
}


//MARK: 🔄 D – Dependency Inversion Principle (DIP)
//High-level modules should not depend on low-level modules.
protocol NetworkServicingProtocol {
    func fetchVideosApi()
}

class NetworkManager : NetworkServicingProtocol {
    func fetchVideosApi() {
        print("Videos")
    }
}

class UserViewModel {
    let service:NetworkServicingProtocol
    init(service : NetworkServicingProtocol) {
        self.service = service
    }
    func fetchVideos() {
        service.fetchVideosApi()
    }
}

