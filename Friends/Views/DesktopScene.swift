//
//  DesktopScene.swift
//  Friends
//
//  Created by Jason Barrie Morley on 06/01/2023.
//

import SwiftUI
import SpriteKit

class DesktopScene: SKScene {

    var windows: [Int: SKSpriteNode] = [:]

    func setup() {
        let startPoint = CGPoint(x: 0, y: 0)
        let endPoint = CGPoint(x: size.width, y: 0)
        physicsBody = SKPhysicsBody(edgeFrom: startPoint, to: endPoint)
        physicsBody?.restitution = 0.8
    }

    func add(location: CGPoint) {
        let box = SKSpriteNode(color: .cyan, size: CGSize(width: 40, height: 40))
        box.position = location
        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 40))
        addChild(box)
    }

    func update(windows: [Int: CGRect]) {

        let currentWindowIDs = Set(self.windows.keys)
        let updatedWindowIDs = Set(windows.keys)

        let removedWindowIDs = currentWindowIDs.subtracting(updatedWindowIDs)
        for windowID in removedWindowIDs {
            self.windows[windowID]?.removeFromParent()
        }
        self.windows = self.windows.filter { !removedWindowIDs.contains($0.key) }

        for windowID in updatedWindowIDs {
            set(windowID: windowID, frame: windows[windowID]!)
        }

    }

    private func set(windowID: Int, frame: CGRect) {
        if let windowSprite = windows[windowID] {
            windowSprite.position = frame.position
            windowSprite.size = frame.size
            // TODO: Update physicsBody shape
        } else {
            let windowSprite = SKSpriteNode(color: .clear, size: frame.size)
            windowSprite.position = frame.position
            let physicsBody = SKPhysicsBody(rectangleOf: frame.size)
            physicsBody.restitution = 0.8
            physicsBody.affectedByGravity = false
            physicsBody.isDynamic = false
            windowSprite.physicsBody = physicsBody
            addChild(windowSprite)
            windows[windowID] = windowSprite
        }
    }

}
