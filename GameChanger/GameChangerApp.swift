//
//  GameChangerApp.swift
//  GameChanger
//
//  Created by Pavan Kumar Reddy on 23/02/26.
//

import SwiftUI

@main
struct GameChangerApp: App {
    @State var vm = GameViewModel()
    var body: some Scene {
        WindowGroup {
            GameDashBoardView()
                .environment(vm)
        }
    }
}

