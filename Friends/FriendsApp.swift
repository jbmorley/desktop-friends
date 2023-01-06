//
//  FriendsApp.swift
//  Friends
//
//  Created by Jason Barrie Morley on 06/01/2023.
//

import SwiftUI
import SpriteKit

@main
struct FriendsApp: App {

    @StateObject var applicationModel = ApplicationModel()

    var body: some Scene {
        MenuBarExtra {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            Image(systemName: "face.smiling")
        }
    }

}
