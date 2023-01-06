//
//  DesktopScene.swift
//  Friends
//
//  Created by Jason Barrie Morley on 06/01/2023.
//

import SwiftUI
import SpriteKit

class DesktopScene: SKScene {

    func add(location: CGPoint) {
        let box = SKSpriteNode(color: .cyan, size: CGSize(width: 40, height: 40))
        box.position = location
        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 40))
        addChild(box)
    }

}
