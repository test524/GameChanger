//
//  GameChangerApp.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 23/02/26.
//

import SwiftUI
import Combine

@main
struct GameChangerApp: App {
    @State var gameVM = GameViewModel()
    @State var auth = AuthenticationService()
    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isLoggedIn == false {
                    LoginView()
                }else{
                    GamePlayView()
                     .environment(gameVM)
                }
            }
            .environment(auth)
        }
    }
}


