//
//  AuthenticationService.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 16/04/26.
//
import Combine
import Foundation

@Observable
class AuthenticationService {

    var isLoggedIn: Bool = false

    init() {
        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    }

    func login() {
        isLoggedIn = true
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
    }

    func logout() {
        isLoggedIn = false
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
    }
}
